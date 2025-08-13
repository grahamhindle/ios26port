import ComposableArchitecture
import CustomDump
import DatabaseModule
import DependenciesTestSupport
import SharingGRDB
import SwiftUI
import Testing
@testable import UserFeature

func prepareTestDatabase() throws -> any DatabaseWriter {
    let database = try withDependencies {
        $0.context = .test
    } operation: {
        try appDatabase()
    }
    prepareDependencies {
        $0.defaultDatabase = database
        $0.context = .test
    }
    return database
}

@MainActor
struct UserFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)

    static var expectedUserCount: Int { 3 }

    @Test func databaseLoads() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let initialState = withDependencies {
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        } operation: {
            UserFeature.State()
        }

        let store = TestStore(initialState: initialState) {
            UserFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        try await store.state.$userRecords.load()
        #expect(store.state.userRecords.count == Self.expectedUserCount)
        #expect(store.state.hasUsers == true)
    }

    @Test func addButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(
                draft: User.Draft()
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

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        if let firstUser = store.state.userRecords.first?.user {
            await store.send(.editButtonTapped(user: firstUser)) {
                $0.userForm = UserFormFeature.State(draft: User.Draft(firstUser))
            }
        }
    }

    @Test func deleteButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        if let firstUser = store.state.userRecords.first?.user {
            await store.send(.deleteButtonTapped(user: firstUser))
        }
        try await store.state.$userRecords.load()
        #expect(store.state.userRecords.count == 2)
    }

    @Test func detailButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Test changing to authenticated users
        await store.send(.detailButtonTapped(detailType: .authenticated)) {
            $0.detailType = .authenticated
        }

        // Test changing to guest users
        await store.send(.detailButtonTapped(detailType: .guests)) {
            $0.detailType = .guests
        }

        // Test changing to premium users
        await store.send(.detailButtonTapped(detailType: .premiumUsers)) {
            $0.detailType = .premiumUsers
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

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.onAppear)
        // onAppear currently returns .none, so no state changes expected
    }

    @Test func userFormDismissal() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        var initialState = withDependencies {
            $0.date = .constant(fixedDate)
        } operation: {
            UserFeature.State()
        }

        // Set up initial state with user form presented
        initialState.userForm = UserFormFeature.State(
            draft: User.Draft(name: "Test User", email: "test@example.com")
        )

        let store = TestStore(initialState: initialState) {
            UserFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        // Test delegate actions that dismiss the form
        await store.send(.userForm(.presented(.delegate(.didFinish)))) {
            $0.userForm = nil
        }
    }

    @Test func statsLoading() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Load stats manually
        try await store.state.$stats.load()

        // Verify stats based on seeded data:
        // - Total: 3 users
        // - Authenticated: 2 users (John Doe and Jane Smith)
        // - Guests: 1 user (Bob Wilson)
        // - Free: 2 users (John Doe and Bob Wilson)
        // - Premium: 1 user (Jane Smith)
        // - Enterprise: 0 users
        #expect(store.state.stats.allCount == 3)
        #expect(store.state.stats.authenticated == 2)
        #expect(store.state.stats.guests == 1)
        #expect(store.state.stats.freeCount == 2)
        #expect(store.state.stats.premiumCount == 1)
        #expect(store.state.stats.enterpriseCount == 0)
    }

    @Test func filteredUserRecords() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Test filtering by detail type

        // All users (default)
        #expect(store.state.filteredUserRecords.count == 3)

        // Authenticated users only
        await store.send(.detailButtonTapped(detailType: .authenticated)) {
            $0.detailType = .authenticated
        }
        #expect(store.state.filteredUserRecords.count == 2)

        // Guest users only
        await store.send(.detailButtonTapped(detailType: .guests)) {
            $0.detailType = .guests
        }
        #expect(store.state.filteredUserRecords.count == 1)

        // Premium users only
        await store.send(.detailButtonTapped(detailType: .premiumUsers)) {
            $0.detailType = .premiumUsers
        }
        #expect(store.state.filteredUserRecords.count == 1)

        // Free users only
        await store.send(.detailButtonTapped(detailType: .freeUsers)) {
            $0.detailType = .freeUsers
        }
        #expect(store.state.filteredUserRecords.count == 2)

        // Back to all
        await store.send(.detailButtonTapped(detailType: .all)) {
            $0.detailType = .all
        }
        #expect(store.state.filteredUserRecords.count == 3)
    }

    @Test func computedProperties() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        try await store.state.$userRecords.load()

        // Test computed properties
        #expect(store.state.hasUsers == true)
        #expect(store.state.currentFilterCount == 3) // All users by default
        #expect(store.state.hasFilteredResults == true)

        // Test with filter that has results
        await store.send(.detailButtonTapped(detailType: .authenticated)) {
            $0.detailType = .authenticated
        }
        #expect(store.state.currentFilterCount == 2) // 2 authenticated users

        // Test with filter that might have no results
        await store.send(.detailButtonTapped(detailType: .enterpriseUsers)) {
            $0.detailType = .enterpriseUsers
        }
        #expect(store.state.currentFilterCount == 0) // No enterprise users
        #expect(store.state.hasFilteredResults == false)
    }

    @Test func userFormLifecycle() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFeature.State()
            },
            reducer: {
                UserFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Test add -> cancel flow
        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(draft: User.Draft())
        }

        await store.send(.userForm(.presented(.delegate(.didCancel)))) {
            $0.userForm = nil
        }

        // Test add -> finish flow
        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(draft: User.Draft())
        }

        await store.send(.userForm(.presented(.delegate(.didFinish)))) {
            $0.userForm = nil
        }
    }
}
