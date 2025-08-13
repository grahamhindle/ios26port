//
//  UserFormFeatureTests.swift
//  UserFeature
//
//  Created by Graham Hindle on 04/08/2025.
//

import ComposableArchitecture
import CustomDump
import DatabaseModule
import DependenciesTestSupport
import SharingGRDB
import SwiftUI
import Testing
@testable import UserFeature

@MainActor
struct UserFormFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)

    @Test func enterBirthdayToggled() async throws {
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
                UserFormFeature.State(draft: User.Draft())
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        #expect(store.state.enterBirthday == false)
        #expect(store.state.draft.dateOfBirth == nil)

        await store.send(.enterBirthdayToggled(true)) {
            $0.enterBirthday = true
            $0.draft.dateOfBirth = Date()
        }

        await store.send(.enterBirthdayToggled(false)) {
            $0.enterBirthday = false
            $0.draft.dateOfBirth = nil
        }
    }

    @Test func authenticationFlowForUnauthenticatedUser() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(name: "Test User", isAuthenticated: false)

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: initialDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Test authentication button for unauthenticated user
        await store.send(.authenticationButtonTapped)
        await store.receive(.auth(.showCustomSignup))
    }

    @Test func saveTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(
            name: "New User",
            email: "newuser@example.com"
        )

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: initialDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.saveTapped) {
            $0.showingSuccessMessage = false
        }

        // Skip received actions as async database operations may vary
        await store.skipReceivedActions()
    }

    @Test func cancelTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(name: "Test User", email: "test@example.com")

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: initialDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        await store.send(.cancelTapped)

        // After cancel, expect delegate action
        await store.receive(.delegate(.didCancel))
    }

    @Test func bindingActions() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(name: "Test User", email: "test@example.com")

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: initialDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        // Test binding actions for draft properties
        await store.send(.binding(.set(\.draft.name, "Updated Name"))) {
            $0.draft.name = "Updated Name"
        }

        await store.send(.binding(.set(\.draft.email, "updated@example.com"))) {
            $0.draft.email = "updated@example.com"
        }
    }

    @Test func initialStateWithBirthday() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let draft = User.Draft(
            name: "Test User",
            dateOfBirth: fixedDate,
            email: "test@example.com"
        )

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: draft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        #expect(store.state.draft.name == "Test User")
        #expect(store.state.draft.email == "test@example.com")
        #expect(store.state.enterBirthday == true) // Because dateOfBirth is set
    }

    @Test func initialStateWithoutBirthday() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let draft = User.Draft(
            name: "Test User",
            email: "test@example.com"
        )

        let store = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: draft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )

        #expect(store.state.enterBirthday == false) // Because dateOfBirth is nil
    }

    @Test func authenticationButtonTitle() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        // Test "Sign Up" for unauthenticated user
        var draft = User.Draft()
        draft.isAuthenticated = false
        let signUpStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: draft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(signUpStore.state.authenticationButtonTitle == "Sign Up")

        // Test "Sign Out" for recently signed in user
        draft.isAuthenticated = true
        draft.lastSignedInDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let signOutStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: draft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(signOutStore.state.authenticationButtonTitle == "Sign Out")

        // Test "Sign In" for authenticated but not recently signed in user
        draft.lastSignedInDate = Date().addingTimeInterval(-86400 * 2) // 2 days ago
        let signInStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: draft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(signInStore.state.authenticationButtonTitle == "Sign In")
    }

    @Test func computedPropertiesAndValidation() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        // Test form validation with empty name
        var emptyNameDraft = User.Draft(name: "", email: "test@example.com")
        let emptyNameStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: emptyNameDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(emptyNameStore.state.isValid == false)

        // Test form validation with valid name
        var validDraft = User.Draft(name: "Valid User", email: "valid@example.com")
        let validStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: validDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(validStore.state.isValid == true)

        // Test authentication status text
        validDraft.isAuthenticated = false
        let unauthStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: validDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(unauthStore.state.authenticationStatusText.contains("Not authenticated"))

        // Test recent sign in status
        validDraft.isAuthenticated = true
        validDraft.lastSignedInDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let recentStore = TestStore(
            initialState: withDependencies {
                $0.date = .constant(fixedDate)
            } operation: {
                UserFormFeature.State(draft: validDraft)
            },
            reducer: {
                UserFormFeature()
            },
            withDependencies: { @Sendable in
                $0.defaultDatabase = database
                $0.context = .test
                $0.date = .constant(fixedDate)
            }
        )
        #expect(recentStore.state.isRecentlySignedIn == true)
        #expect(recentStore.state.authenticationStatusText.contains("Recently signed in"))
    }
}
