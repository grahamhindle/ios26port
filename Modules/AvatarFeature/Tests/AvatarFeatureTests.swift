//
//  AvatarFeatureTests.swift
//  AvatarFeatureTests
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

@testable import AvatarFeature
import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import SharedModels
import SharingGRDB
import SwiftUI
import Testing

/*
 TCA + SharingGRDB Testing Setup Documentation
 ============================================

 This file demonstrates the correct approach for testing TCA features that use
 SharingGRDB's @FetchAll and @FetchOne property wrappers.

 ## Problem Statement
 When testing TCA reducers with @FetchAll/@FetchOne property wrappers, the standard
 @Suite(.dependency(\.defaultDatabase, ...)) approach doesn't work reliably.
 The property wrappers initialize before the TestStore can apply dependencies,
 causing them to fall back to SharingGRDB's default blank in-memory database.

 ## Root Cause
 1. @FetchAll property wrappers access \.defaultDatabase during State initialization
 2. @Suite dependency injection happens too late in the initialization process
 3. SharingGRDB's DefaultDatabaseKey.testValue creates blank in-memory database
 4. This triggers "Issue recorded at DefaultDatabase.swift:42:42" warnings

 ## Working Solution: prepareDependencies Method
 Use prepareDependencies within individual test methods BEFORE creating any State
 that contains @FetchAll/@FetchOne property wrappers:

 ```swift
 @Test func myTest() async throws {
 // 1. Create the database with seeded data
 let database = try withDependencies {
 $0.context = .test
 } operation: {
 try appDatabase() // This runs migrations + seeding
 }

 // 2. Set global dependencies BEFORE State creation
 prepareDependencies {
 $0.defaultDatabase = database
 $0.context = .test
 }

 // 3. Now @FetchAll will use the seeded database
 let state = AvatarFeature.State() // @FetchAll connects to seeded DB
 let store = await TestStore(initialState: state) {
 AvatarFeature()
 }

 // 4. Verify database connectivity
 #expect(await store.state.avatarRecords.count > 0)
 }

 */

@MainActor
struct AvatarFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)

    static var expectedAvatarRecords: [AvatarFeature.State.AvatarRecords] {
        let d = fixedDate
        return [
            AvatarFeature.State.AvatarRecords(avatar:
                Avatar(
                    id: 2,
                               avatarId: "avatar_002",
                               name: "Casual Walker",
                               subtitle: "Enjoying the park",

                               promptCategory: .travel,
                               promptCharacterType: .mentor,
                               promptCharacterMood: .friendly,
                               profileImageName: "avatar_casual_woman",
                               profileImageURL: "https://picsum.photos/600/600",
                               thumbnailURL: "https://picsum.photos/600/600",
                               userId: 2,

                               isPublic: true,
                               dateCreated: Date().addingTimeInterval(-86400),
                               dateModified: Date().addingTimeInterval(-3600)
                )
            ),
            AvatarFeature.State.AvatarRecords(avatar:
                Avatar(
                    id: 3,
                    avatarId: "avatar_002",
                                name: "Casual Walker",
                                subtitle: "Enjoying the park",

                                promptCategory: .travel,
                                promptCharacterType: .mentor,
                                promptCharacterMood: .friendly,
                                profileImageName: "avatar_casual_woman",
                                profileImageURL: "https://picsum.photos/600/600",
                                thumbnailURL: "https://picsum.photos/600/600",
                                userId: 3,

                                isPublic: true,
                                dateCreated: Date().addingTimeInterval(-86400),
                                dateModified: Date().addingTimeInterval(-3600)
                    )
                ),
                AvatarFeature.State.AvatarRecords(avatar:
                    Avatar(
                        id: 1,
                        avatarId: "avatar_001",
                                   name: "Business Professional",
                                   subtitle: "Ready for meetings",

                                   promptCategory: .business,
                                   promptCharacterType: .professional,
                                   promptCharacterMood: .helpful,
                                   profileImageName: "avatar_business_man",
                                   profileImageURL: "https://picsum.photos/600/600",
                                   thumbnailURL: "https://picsum.photos/600/600",
                                   userId: 1,

                                   isPublic: true,
                                   dateCreated: Date(),
                                   dateModified: Date()
                    )
                )
        ]
    }

    @Test func databaseLoads() async throws {
        // Set up database dependency using prepareTestDatabase helper wrapped with fixedDate dependency
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        print("🔥 Starting test with suite database: \(database)")

        // First, let's verify the database has data directly
        let avatarCount = try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM avatar") ?? 0
        }
        print("🔥 Direct query shows \(avatarCount) avatars in database")

        let fixedDate = Self.fixedDate

        // Create the state within the dependency context so @FetchAll captures the right database and fixedDate
        let initialState = withDependencies {
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        } operation: {
            AvatarFeature.State()
        }

        let store = TestStore(initialState: initialState) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        // Now test if @FetchAll works
        print("🔥 Store state has \(store.state.avatarRecords.count) avatar records")

        // Try to load the @FetchAll manually
        try await store.state.$avatarRecords.load()

        expectNoDifference(store.state.avatarRecords, Self.expectedAvatarRecords)
    }

    @Test func getRecords() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }
        // load the data
        try await store.state.$avatarRecords.load()
        expectNoDifference(store.state.avatarRecords, Self.expectedAvatarRecords)
    }

    @Test func deleteButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        if let firstAvatar = store.state.avatarRecords.first?.avatar {
            await store.send(.deleteButtonTapped(avatar: firstAvatar))
        }
        try await store.state.$avatarRecords.load()
        #expect(store.state.avatarRecords.count == 2)
        let actualIds = store.state.avatarRecords.map(\.avatar.id)
        #expect(actualIds == [3, 1])
    }
    
    @Test func addButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        await store.send(.addButtonTapped) {
            $0.avatarForm = AvatarFormFeature.State(
                draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
            )
        }
    }
    
    @Test func editButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        if let firstAvatar = store.state.avatarRecords.first?.avatar {
            await store.send(.editButtonTapped(avatar: firstAvatar)) {
                $0.avatarForm = AvatarFormFeature.State(draft: Avatar.Draft(firstAvatar))
            }
        }
    }
    
    @Test func detailButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        // Test changing to public avatars
        await store.send(.detailButtonTapped(detailType: .publicAvatars)) {
            $0.detailType = .publicAvatars
        }
        
        // Test changing to private avatars
        await store.send(.detailButtonTapped(detailType: .privateAvatars)) {
            $0.detailType = .privateAvatars
        }
        
        // Test changing back to all
        await store.send(.detailButtonTapped(detailType: .all)) {
            $0.detailType = .all
        }
    }
    
    @Test func onAppear() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        await store.send(.onAppear)
        // onAppear currently returns .none, so no state changes expected
    }
    
    @Test func avatarFormDismissal() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        var initialState = withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }
        
        // Set up initial state with avatar form presented
        initialState.avatarForm = AvatarFormFeature.State(
            draft: Avatar.Draft(name: "Test", userId: 1, isPublic: true)
        )

        let store = TestStore(initialState: initialState) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        // Test delegate actions that dismiss the form
        await store.send(.avatarForm(.presented(.delegate(.didFinish)))) {
            $0.avatarForm = nil
        }
    }
    
    @Test func statsLoading() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        // Load stats manually
        try await store.state.$stats.load()
        
        // Verify stats based on seeded data:
        // - Total: 3 avatars
        // - Public: 2 avatars (Alex Creative and Sarah Professional)  
        // - Private: 1 avatar (Chris Casual)
        #expect(store.state.stats.allCount == 3)
        #expect(store.state.stats.publicCount == 2)
        #expect(store.state.stats.privateCount == 1)
    }
    
    @Test func filteredAvatarRecords() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFeature.State()
        }) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
            $0.date = .constant(fixedDate)
        }

        // Test filtering by detail type
        
        // All avatars (default)
        #expect(store.state.filteredAvatarRecords.count == 3)
        
        // Public avatars only
        await store.send(.detailButtonTapped(detailType: .publicAvatars)) {
            $0.detailType = .publicAvatars
        }
        #expect(store.state.filteredAvatarRecords.count == 2)
        
        // Private avatars only  
        await store.send(.detailButtonTapped(detailType: .privateAvatars)) {
            $0.detailType = .privateAvatars
        }
        #expect(store.state.filteredAvatarRecords.count == 1)
        
        // Back to all
        await store.send(.detailButtonTapped(detailType: .all)) {
            $0.detailType = .all
        }
        #expect(store.state.filteredAvatarRecords.count == 3)
    }
}
