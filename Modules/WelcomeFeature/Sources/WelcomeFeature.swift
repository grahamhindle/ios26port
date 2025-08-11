//
//  WelcomeFeature.swift
//  WelcomeFeature
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import SharingGRDB

@Reducer
public struct WelcomeFeature {
    public init() {}

    @ObservableState
    public struct State: Sendable, Equatable {
        @ObservationStateIgnored
        @FetchOne var selectedUser: User?
        // @FetchAll(User.all) public var users: [User]
        public var users: [User] = []
        public var auth = AuthFeature.State()
        public var isCreatingGuestUser = false

        public init() {}
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case signInTapped
        case startTapped
        case showTabBar

        case setCreatingGuestUser(Bool)
        case userLoaded(User?)
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
        BindingReducer()
        
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .signInTapped:

                return .send(.auth(.signIn))
            case .startTapped:
                state.isCreatingGuestUser = true
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

                return .run { [database] send in
                    await withErrorReporting {
                        // Insert the user and get the inserted user
                        let insertedUser = try await database.write { database in
                            return try User.upsert { draftUser }.returning(\.self).fetchOne(database)
                        }

                        // Send guest user to onboarding
                        if let user = insertedUser {
                            await send(.delegate(.showOnboarding(user)))
                        }
                    }
                    await send(.setCreatingGuestUser(false))
                }
            case .showTabBar:
                return .none
            case let .setCreatingGuestUser(isCreating):
                state.isCreatingGuestUser = isCreating
                return .none
            case let .userLoaded(user):
                if let user = user {
                    return .send(.delegate(.didAuthenticate(user)))
                }
                return .none
            case .delegate:
                return .none
            case let .auth(.authenticationSucceeded(authId, provider, email)):
                // Don't allow sign-in while creating guest user

                guard !state.isCreatingGuestUser else { return .none }
                print("🔍 Auth success - authId: '\(authId)', provider: \(provider ?? "nil"), email: \(email ?? "nil")")

                return .run { [database, selectedUser = state.$selectedUser] send in
                    await withErrorReporting {
                        // Fetch the user directly from database
                        let user = try await database.read { database in
                            try User.where { $0.authId.eq(authId) }.fetchOne(database)
                        }
                        
                        if let user = user {
                            // Update lastSignedInDate in database using User.upsert
                            try await database.write { database in
                                var draft = User.Draft(user)
                                draft.lastSignedInDate = Date()
                                draft.email = email
                                draft.providerID = provider
                                draft.authId = authId
                                draft.isAuthenticated = true
                                try User.upsert { draft }.execute(database)
                            }
                            // Send authenticated user to delegate
                            // let authenticatedUser = User(
                            //     id: user.id,
                            //     name: user.name,
                            //     dateOfBirth: user.dateOfBirth,
                            //     email: email,
                            //     dateCreated: user.dateCreated,
                            //     lastSignedInDate: Date(),
                            //     authId: authId,
                            //     isAuthenticated: true,
                            //     providerID: provider,
                            //     membershipStatus: user.membershipStatus,
                            //     authorizationStatus: user.authorizationStatus,
                            //     themeColorHex: user.themeColorHex,
                            //     profileCreatedAt: user.profileCreatedAt,
                            //     profileUpdatedAt: user.profileUpdatedAt
                            // )
                            // await send(.delegate(.didAuthenticate(authenticatedUser)))
                            print("Authentication successful for user: \(user.name)")
                            
                            // Reload the selectedUser to get the updated data
                            try await selectedUser.load(
                                User.where { $0.authId.eq(authId) }
                            )
                            
                            // Send the updated user from state to delegate
                            if let updatedUser = selectedUser.wrappedValue {
                                print("Updated user authId: \(updatedUser.authId ?? "nil")")
                                let testUser = updatedUser
                                await send(.delegate(.didAuthenticate(testUser)))
                            }
                        } else {
                            print("🔍 No user found with authId: \(authId) - user needs onboarding")
                            // TODO: Show onboarding flow for authenticated user without record
                        }
                    }
                }
            case let .auth(.authenticationFailed(error)):
                print("Authentication failed: \(error)")
                return .none
            case .auth:
                return .none
            }
        }
    }
}
