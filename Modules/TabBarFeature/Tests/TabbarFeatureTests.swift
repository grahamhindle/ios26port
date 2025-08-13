//
//  TabBarFeatureTests.swift
//  TabBarFeature
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import DatabaseModule
import DependenciesTestSupport
import Foundation
import Testing
@testable import TabBarFeature

@MainActor
struct TabBarFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)
    
    @Test func testOnAppear() async throws {
        let testUser = User(
            id: 1,
            name: "Test User",
            dateOfBirth: Self.fixedDate,
            email: "test@example.com",
            dateCreated: Self.fixedDate,
            lastSignedInDate: Self.fixedDate,
            authId: "auth123",
            isAuthenticated: true,
            providerID: "provider123",
            membershipStatus: .free,
            authorizationStatus: .authorized,
            themeColorHex: 0x007AFF,
            profileCreatedAt: Self.fixedDate,
            profileUpdatedAt: Self.fixedDate
        )
        
        let store = TestStore(
            initialState: TabBarFeature.State(user: testUser)
        ) {
            TabBarFeature()
        }

        await store.send(.onAppear) {
            // Verify state changes if any
        }

        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
    
    @Test func testTabSelection() async throws {
        let testUser = User(
            id: 1,
            name: "Test User",
            dateOfBirth: Self.fixedDate,
            email: "test@example.com",
            dateCreated: Self.fixedDate,
            lastSignedInDate: Self.fixedDate,
            authId: "auth123",
            isAuthenticated: true,
            providerID: "provider123",
            membershipStatus: .free,
            authorizationStatus: .authorized,
            themeColorHex: 0x007AFF,
            profileCreatedAt: Self.fixedDate,
            profileUpdatedAt: Self.fixedDate
        )
        
        let store = TestStore(
            initialState: TabBarFeature.State(user: testUser)
        ) {
            TabBarFeature()
        }
        
        // Test tab selection
        await store.send(.tabSelected(.chat)) {
            $0.selectedTab = .chat
        }
        
        await store.send(.tabSelected(.userProfile)) {
            $0.selectedTab = .userProfile
        }
        
        await store.send(.tabSelected(.explore)) {
            $0.selectedTab = .explore
        }
    }
    
    @Test func testEditProfileTapped() async throws {
        let testUser = User(
            id: 1,
            name: "Test User",
            dateOfBirth: Self.fixedDate,
            email: "test@example.com",
            dateCreated: Self.fixedDate,
            lastSignedInDate: Self.fixedDate,
            authId: "auth123",
            isAuthenticated: true,
            providerID: "provider123",
            membershipStatus: .free,
            authorizationStatus: .authorized,
            themeColorHex: 0x007AFF,
            profileCreatedAt: Self.fixedDate,
            profileUpdatedAt: Self.fixedDate
        )
        
        let store = TestStore(
            initialState: TabBarFeature.State(user: testUser)
        ) {
            TabBarFeature()
        }
        
        // Test edit profile button
        await store.send(.editProfileTapped) {
            $0.showingProfileForm = true
        }
    }
}
