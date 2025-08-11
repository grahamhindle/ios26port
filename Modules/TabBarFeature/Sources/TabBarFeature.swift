//
//  TabBarFeature.swift
//  Tabbar
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import Chat
import ComposableArchitecture
import Explore

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
        var exploreState: ExploreFeature.State
        var chatState: ChatFeature.State
        @Presents var profileForm: UserFormFeature.State?

        public init(user: User) {
            self.user = user
            self.exploreState = ExploreFeature.State(userId: user.id)
            self.chatState = ChatFeature.State(userId: user.id)
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case tabSelected(Tab)
        case explore(ExploreFeature.Action)
        case chat(ChatFeature.Action)
        case editProfileTapped
        case profileForm(PresentationAction<UserFormFeature.Action>)
        case delegate(Delegate)
        
        public enum Delegate: Equatable, Sendable {
            case didSignOut
        }
    }

    public enum Tab: String, CaseIterable, Sendable {
        case explore = "Explore"
        case chat = "Chat"
        case profile = "Profile"

        var systemImage: String {
            switch self {
            case .explore: "eyes"
            case .chat: "bubble.left.and.bubble.right.fill"
            case .profile: "person.fill"
            }
        }
    }


    public var body: some ReducerOf<Self> {
        Scope(state: \.exploreState, action: \.explore) {
            ExploreFeature()
        }

        Scope(state: \.chatState, action: \.chat) {
            ChatFeature()
        }

        .ifLet(\.$profileForm, action: \.profileForm) {
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
                let userDraft = User.Draft(
                    id: state.user.id,
                    name: state.user.name,
                    dateOfBirth: state.user.dateOfBirth,
                    email: state.user.email,
                    dateCreated: state.user.dateCreated,
                    lastSignedInDate: state.user.lastSignedInDate,
                    authId: state.user.authId,
                    isAuthenticated: state.user.isAuthenticated,
                    providerID: state.user.providerID,
                    membershipStatus: state.user.membershipStatus,
                    authorizationStatus: state.user.authorizationStatus,
                    themeColorHex: state.user.themeColorHex,
                    profileCreatedAt: state.user.profileCreatedAt,
                    profileUpdatedAt: state.user.profileUpdatedAt
                )
                state.profileForm = UserFormFeature.State(draft: userDraft)
                return .none
                
            case .profileForm(.presented(.delegate(.didSignOut))):
                // Handle successful sign out - delegate to parent (AppFeature)
                return .send(.delegate(.didSignOut))
                
            case .profileForm(.presented(.delegate(.didFinish))):
                state.profileForm = nil
                return .none
                
            case let .profileForm(.presented(.delegate(.didFinishWithUpdatedUser(updatedUser)))):
                // Update the user state with the updated user data
                state.user = updatedUser
                state.profileForm = nil
                return .none
                
            case .profileForm(.presented(.delegate(.didCancel))):
                state.profileForm = nil
                return .none
                
            case .profileForm:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

