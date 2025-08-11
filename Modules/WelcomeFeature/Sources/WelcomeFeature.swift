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
                            let insertRequest = User.upsert { draftUser }.returning(\.self)
                            return try insertRequest.fetchOne(database)
                        }

                        // Update state with the loaded user
                        await send(.userLoaded(insertedUser))
                    }
                    await send(.setCreatingGuestUser(false))
                }
            case .showTabBar:
                return .none
            case let .setCreatingGuestUser(isCreating):
                state.isCreatingGuestUser = isCreating
                return .none
            case let .userLoaded(user):
//                if let user = user {
//                    try? state.$selectedUser.load()
//                }
                return .none
            case .delegate:
                return .none
            case let .auth(.authenticationSucceeded(authId, provider, email)):
                // Don't allow sign-in while creating guest user

                guard !state.isCreatingGuestUser else { return .none }
                print("🔍 Auth success - authId: '\(authId)', provider: \(provider ?? "nil"), email: \(email ?? "nil")")
                // TODO: - update user record in database - only last signed in date
//                return .run { [database, currentUser = state.$selectedUser] send in
//                    await withErrorReporting {
                        // Fetch the user by authId
//                        try await currentUser.load(
//                            User.where { $0.authId.eq(authId) }
//                        )
////                        
////                        // Update the user's lastSignedInDate
//                        currentUser.lastSignedInDate = Date()
//                        try await database.write { database in
//                            try User.update(currentUser).execute(database)
//                        }
                        return .run { [database, currentUser = state.$selectedUser] send in
                            await withErrorReporting {
                                // Fetch the user by authId
                                try await currentUser.load(
                                    User.where { $0.authId.eq(authId) }
                                )
                                
                                // Update lastSignedInDate in database using User.upsert
                                if let user = currentUser.wrappedValue {
                                    try await database.write { database in
                                        var draft = User.Draft(user)
                                        draft.lastSignedInDate = Date()
                                        draft.email = email
                                        draft.providerID = provider
                                        draft.authId = authId
                                        try User.upsert { draft }.execute(database)
                                    }

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
