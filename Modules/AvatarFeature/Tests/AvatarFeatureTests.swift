//
//  AvatarFeatureTests.swift
//  AvatarFeatureTests
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

@testable import AvatarFeature
import ComposableArchitecture

import DatabaseModule
import DependenciesTestSupport
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
struct AvatarFeatureDatabaseTests {
    @Test func databaseLoads() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        print("🔥 Starting test with suite database: \(database)")

        let avatarCount = try await database.read { data in
            try Int.fetchOne(data, sql: "SELECT COUNT(*) FROM avatar") ?? 0
        }
        print("🔥 Direct query shows \(avatarCount) avatars in database")

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

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

        print("🔥 Store state has \(store.state.avatarRecords.count) avatar records")
        try await store.state.$avatarRecords.load()
        #expect(store.state.avatarRecords.count == AvatarFeatureTestHelpers.expectedAvatarCount)
    }

    @Test func getRecords() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )
        try await store.state.$avatarRecords.load()
        #expect(store.state.avatarRecords.count == AvatarFeatureTestHelpers.expectedAvatarCount)
    }
}

@MainActor
struct AvatarFeatureActionTests {
    @Test func deleteButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

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
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.addButtonTapped) {
            $0.avatarForm = AvatarFormFeature.State(
                draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
            )
        }
    }

    @Test func editButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        if let firstAvatar = store.state.avatarRecords.first?.avatar {
            await store.send(.editButtonTapped(avatar: firstAvatar)) {
                $0.avatarForm = AvatarFormFeature.State(draft: Avatar.Draft(firstAvatar))
            }
        }
    }

    @Test func detailButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.detailButtonTapped(detailType: .publicAvatars)) {
            $0.detailType = .publicAvatars
        }
        await store.send(.detailButtonTapped(detailType: .privateAvatars)) {
            $0.detailType = .privateAvatars
        }
        await store.send(.detailButtonTapped(detailType: .all)) {
            $0.detailType = .all
        }
    }

    @Test func onAppear() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.onAppear)
    }

    @Test func avatarFormDismissal() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        var initialState = withDependencies({
            $0.date = .constant(fixedDate)
        }, operation: {
            AvatarFeature.State()
        })

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

        await store.send(.avatarForm(.presented(.delegate(.didFinish)))) {
            $0.avatarForm = nil
        }
    }
}

@MainActor
struct AvatarFeatureStatsTests {
    @Test func statsLoading() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        try await store.state.$stats.load()
        #expect(store.state.stats.allCount == 3)
        #expect(store.state.stats.publicCount == 2)
        #expect(store.state.stats.privateCount == 1)
    }

    @Test func filteredAvatarRecords() async throws {
        let database = try withDependencies {
            $0.date = .constant(AvatarFeatureTestHelpers.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = AvatarFeatureTestHelpers.fixedDate

        let store = TestStore(
            initialState: withDependencies({
                $0.date = .constant(fixedDate)
            }, operation: {
                AvatarFeature.State()
            }),
            reducer: {
                AvatarFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.currentUserId = { 1 }
                $0.date = .constant(fixedDate)
            }
        )

        #expect(store.state.filteredAvatarRecords.count == 3)
        await store.send(.detailButtonTapped(detailType: .publicAvatars)) {
            $0.detailType = .publicAvatars
        }
        #expect(store.state.filteredAvatarRecords.count == 2)
        await store.send(.detailButtonTapped(detailType: .privateAvatars)) {
            $0.detailType = .privateAvatars
        }
        #expect(store.state.filteredAvatarRecords.count == 1)
        await store.send(.detailButtonTapped(detailType: .all)) {
            $0.detailType = .all
        }
        #expect(store.state.filteredAvatarRecords.count == 3)
    }
}
