//
//  TabBarFeature.swift
//  Tabbar
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//
import AvatarFeature
import Chat
import ComposableArchitecture
import DatabaseModule
import SharedResources
import SharingGRDB
import SwiftUI
import UserFeature

@Reducer
public struct TabBarFeature {
    public init() {}

    @ObservableState
    public struct State: Sendable, Equatable {
        var user: User
        var selectedTab: Tab = .explore
        var exploreState: AvatarFeature.State
        var chatState: ChatFeature.State
        var userFormState: UserFormFeature.State
        var showingProfileForm = false

        public init(user: User) {
            self.user = user
            exploreState = AvatarFeature.State(user: user)
            chatState = ChatFeature.State(userId: user.id)

            let userDraft = User.Draft(
                id: user.id,
                name: user.name,
                dateOfBirth: user.dateOfBirth,
                email: user.email,
                dateCreated: user.dateCreated,
                lastSignedInDate: user.lastSignedInDate,
                authId: user.authId,
                isAuthenticated: user.isAuthenticated,
                providerID: user.providerID,
                membershipStatus: user.membershipStatus,
                authorizationStatus: user.authorizationStatus,
                themeColorHex: user.themeColorHex,
                profileCreatedAt: user.profileCreatedAt,
                profileUpdatedAt: user.profileUpdatedAt
            )
            userFormState = UserFormFeature.State(draft: userDraft)
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case tabSelected(Tab)
        case explore(AvatarFeature.Action)
        case chat(ChatFeature.Action)
        case editProfileTapped
        case userForm(UserFormFeature.Action)
        case delegate(Delegate)
        // swiftlint:disable nesting
        public enum Delegate: Equatable, Sendable {
            
            case didSignOut
        }
    }
    // swiftlint:enable nesting

    public enum Tab: String, CaseIterable, Sendable {
        case explore = "Explore"
        case chat = "Chat"
        case userProfile = "Profile"

        var systemImage: String {
            switch self {
            case .explore: "eyes"
            case .chat: "bubble.left.and.bubble.right.fill"
            case .userProfile: "person.fill"
            }
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.exploreState, action: \.explore) {
            AvatarFeature()
        }

        Scope(state: \.chatState, action: \.chat) {
            ChatFeature()
        }

        Scope(state: \.userFormState, action: \.userForm) {
            UserFormFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .explore, .chat:
                return .none

            case .editProfileTapped:
                state.showingProfileForm = true
                return .none

            case .userForm(.delegate(.didSignOut)):
                print("🔍 TabBarFeature: Received didSignOut from UserForm, delegating to AppFeature")
                // Handle successful sign out - delegate to parent (AppFeature)
                return .send(.delegate(.didSignOut))

            case .userForm(.delegate(.didFinish)):
                state.showingProfileForm = false
                return .none

            case let .userForm(.delegate(.didFinishWithUpdatedUser(updatedUser))):
                // Update the user state with the updated user data
                state.user = updatedUser
                // Update the user form state with the new user data
                let userDraft = User.Draft(
                    id: updatedUser.id,
                    name: updatedUser.name,
                    dateOfBirth: updatedUser.dateOfBirth,
                    email: updatedUser.email,
                    dateCreated: updatedUser.dateCreated,
                    lastSignedInDate: updatedUser.lastSignedInDate,
                    authId: updatedUser.authId,
                    isAuthenticated: updatedUser.isAuthenticated,
                    providerID: updatedUser.providerID,
                    membershipStatus: updatedUser.membershipStatus,
                    authorizationStatus: updatedUser.authorizationStatus,
                    themeColorHex: updatedUser.themeColorHex,
                    profileCreatedAt: updatedUser.profileCreatedAt,
                    profileUpdatedAt: updatedUser.profileUpdatedAt
                )
                state.userFormState = UserFormFeature.State(draft: userDraft)
                state.showingProfileForm = false
                return .none

            case .userForm(.delegate(.didCancel)):
                state.showingProfileForm = false
                return .none

            case .userForm:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
