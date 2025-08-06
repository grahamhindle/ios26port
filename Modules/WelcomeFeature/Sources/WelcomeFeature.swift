//
//  WelcomeFeature.swift
//  WelcomeFeature
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import SharingGRDB
import StructuredQueriesGRDB

@Reducer
public struct WelcomeFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        @FetchOne var user: User?

        public var auth = AuthFeature.State()
        public var isCreatingGuestUser = false

        public init() {}
    }

    public enum Action: Sendable {
        case signInTapped
        case startTapped
        case setCreatingGuestUser(Bool)
        case auth(AuthFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case showSignIn
            case didAuthenticate(User)
            case showOnboarding(User)
        }
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }

        Reduce { state, action in
            switch action {
            case .signInTapped:
                // Don't allow sign-in while creating guest user
                guard !state.isCreatingGuestUser else { return .none }
                return .send(.auth(.signIn))

            case .startTapped:
                let draftUser = User.Draft(
                    dateCreated: Date(),
                    lastSignedInDate: nil,
                    authId: nil,
                    isAuthenticated: false,
                    providerID: nil,
                    membershipStatus: .free,
                    authorizationStatus: .guest,
                    themeColorHex: 0x4_4A99_EFFF,
                    profileCreatedAt: Date(),
                    profileUpdatedAt: Date()
                )

                return .run { [database, user = state.$user] send in
                    await withErrorReporting {
                        // Insert the user and get the inserted user ID synchronously
                        let id = try await database.write { database in
                            try User.insert { draftUser }.returning(\.id).fetchOne(database)!
                        }
                        // Now asynchronously load the user
                        try await user.load(
                            User.self
                                .where { $0.id.eq(id) }
                        )
                    }
                    await send(.setCreatingGuestUser(false))
                }

            case let .setCreatingGuestUser(isCreating):
                state.isCreatingGuestUser = isCreating
                return .none

            case let .auth(.authenticationSucceeded(authId, provider, email)):
                // Don't handle auth success while creating guest user
                guard !state.isCreatingGuestUser else { return .none }
                print("🔍 Auth success - authId: '\(authId)', provider: \(provider ?? "nil"), email: \(email ?? "nil")")
                return .run { [database, user = state.$user] _ in
                    await withErrorReporting {
                        // Try to load the user by authId
                        let existingUser = try await database.read { db in
                            try User
                                .where { $0.authId.eq(authId) }
                                .fetchOne(db)
                        }

                        let draft: User.Draft
                        if let existingUser {
                            print("🔍 Found existing user ID: \(existingUser.id)")
                            draft = User.Draft(
                                id: existingUser.id,
                                name: existingUser.name,
                                email: email,
                                dateCreated: existingUser.dateCreated,
                                lastSignedInDate: Date(), // update sign-in date
                                authId: authId,
                                isAuthenticated: true,
                                providerID: provider,
                                membershipStatus: existingUser.membershipStatus,
                                authorizationStatus: .authorized,
                                themeColorHex: existingUser.themeColorHex,
                                profileCreatedAt: existingUser.profileCreatedAt,
                                profileUpdatedAt: Date()
                            )
                            print("🔍 Draft ID set to: \(draft.id)")
                        } else {
                            print("🔍 No existing user found, creating new")
                            draft = User.Draft(
                                name: email?.components(separatedBy: "@").first ?? "New User",
                                email: email,
                                dateCreated: Date(),
                                lastSignedInDate: Date(),
                                authId: authId,
                                isAuthenticated: true,
                                providerID: provider,
                                membershipStatus: .free,
                                authorizationStatus: .authorized,
                                themeColorHex: 0x4_4A99_EFFF,
                                profileCreatedAt: Date(),
                                profileUpdatedAt: Date()
                            )
                        }

                        try await database.write { db in
                            let result = try User.upsert { draft }.returning(\.id).fetchOne(db)
                            print("🔍 Upsert returned ID: \(result)")    
                        }

                    }
                }

            case let .auth(.authenticationFailed(error)):
                print("Authentication failed: \(error)")
                return .none

            case .delegate:
                return .none

            case .auth(.setLoading):
                return .none

            case .auth:
                return .none
            }
        }
    }
}
