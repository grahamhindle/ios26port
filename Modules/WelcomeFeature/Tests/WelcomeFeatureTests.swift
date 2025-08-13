//
//  WelcomeFeatureTests.swift
//  WelcomeFeature
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import DatabaseModule
import DependenciesTestSupport
import Foundation
import Testing
@testable import WelcomeFeature

@MainActor
struct WelcomeFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)
    
    @Test func testSignInTapped() async throws {
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.signInTapped) {
            // Should trigger auth action
        }
        
        await store.receive(.auth(.showCustomLogin))
    }
    
    @Test func testStartTapped() async throws {
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.startTapped) {
            $0.isCreatingGuestUser = true
        }
        
        // Note: The actual guest user creation happens in a .run effect
        // We can't easily test the async database operation in unit tests
        // This test focuses on the immediate state change
    }
    
    @Test func testUserLoaded() async throws {
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
            themeColorHex: 0x4_4A99_EFFF,
            profileCreatedAt: Self.fixedDate,
            profileUpdatedAt: Self.fixedDate
        )
        
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.userLoaded(testUser)) {
            // Should trigger delegate action
        }
        
        await store.receive(.delegate(.didAuthenticate(testUser)))
    }
    
    @Test func testUserLoadedNil() async throws {
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.userLoaded(nil)) {
            // No state changes expected
        }
    }
    
    @Test func testSetCreatingGuestUser() async throws {
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.setCreatingGuestUser(true)) {
            $0.isCreatingGuestUser = true
        }
        
        await store.send(.setCreatingGuestUser(false)) {
            $0.isCreatingGuestUser = false
        }
    }
    
    @Test func testShowTabBar() async throws {
        let store = TestStore(
            initialState: WelcomeFeature.State()
        ) {
            WelcomeFeature()
        }
        
        await store.send(.showTabBar) {
            // No state changes expected
        }
    }
}
