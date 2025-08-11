//
//  TabbarView.swift
//  Tabbar
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//
import Charts
import Chat
import ComposableArchitecture
import Explore

import DatabaseModule
import SharedResources
import UserFeature
import SwiftUI

@MainActor
public struct TabBarView: View {
    @Bindable var store: StoreOf<TabBarFeature>

    public init(store: StoreOf<TabBarFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ExploreView(
                store: store.scope(state: \.exploreState, action: \.explore)
            )
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            .tag(TabBarFeature.Tab.explore)

            ChatView(
                store: store.scope(state: \.chatState, action: \.chat)
            )
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(TabBarFeature.Tab.chat)

            ProfileOverviewView(store: store)
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(TabBarFeature.Tab.profile)
        }
        .tint(SharedColors.accent)
        .sheet(
            store: store.scope(state: \.$profileForm, action: \.profileForm)
        ) { profileFormStore in
            NavigationStack {
                UserFormView(store: profileFormStore)
                    .navigationTitle("Edit Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ProfileOverviewView: View {
    let store: StoreOf<TabBarFeature>
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color(hex: store.user.themeColorHex))
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text(store.user.name.prefix(1).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if let email = store.user.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            store.send(.editProfileTapped)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(store.user.isAuthenticated ? "Authenticated" : "Not Authenticated")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                        .background(store.user.isAuthenticated ? .green : .orange)
                        .cornerRadius(10)
                }
                
                if let providerID = store.user.providerID {
                    HStack {
                        Text("Provider")
                        Spacer()
                        Text(providerID)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Membership")
                    Spacer()
                    Text(store.user.membershipStatus.rawValue)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: store.user.membershipStatus.color))
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    TabBarView(
        store: Store(initialState: TabBarFeature.State(
            user: User(id: 1, name: "Graham",
                                   dateCreated: Date(),
                                   lastSignedInDate: nil,
                                   authId: nil,
                                   isAuthenticated: false,
                                   providerID: nil,
                                   membershipStatus: .free,
                                   authorizationStatus: .guest,
                                   themeColorHex: 0x4_4A99_EFFF,
                                   profileCreatedAt: Date(),
                                   profileUpdatedAt: Date())
                   )) {
            TabBarFeature()
        }
    )
}
