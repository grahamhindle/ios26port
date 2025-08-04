//
//  UserFormFeatureTests.swift
//  UserFeature
//
//  Created by Graham Hindle on 04/08/2025.
//

@testable import UserFeature
import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import SharedModels
import SharingGRDB
import SwiftUI
import Testing

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

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: User.Draft())
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

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

    @Test func authenticationButtonTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(name: "Test User", email: "test@example.com")

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: initialDraft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.authenticationButtonTapped)
        // Currently a placeholder, so no state changes expected
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

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: initialDraft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.saveTapped)

        // After save, expect delegate action
        await store.receive(.delegate(.didFinish))
    }

    @Test func cancelTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = User.Draft(name: "Test User", email: "test@example.com")

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: initialDraft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

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

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: initialDraft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

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

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

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

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

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
        let signUpStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(signUpStore.state.authenticationButtonTitle == "Sign Up")

        // Test "Sign Out" for recently signed in user
        draft.isAuthenticated = true
        draft.lastSignedInDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let signOutStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(signOutStore.state.authenticationButtonTitle == "Sign Out")

        // Test "Sign In" for authenticated but not recently signed in user
        draft.lastSignedInDate = Date().addingTimeInterval(-86400 * 2) // 2 days ago
        let signInStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(signInStore.state.authenticationButtonTitle == "Sign In")
    }

    @Test func isRecentlySignedIn() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        var draft = User.Draft()

        // Test no sign in date
        draft.lastSignedInDate = nil
        let noDateStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(noDateStore.state.isRecentlySignedIn == false)

        // Test recent sign in (1 hour ago)
        draft.lastSignedInDate = Date().addingTimeInterval(-3600)
        let recentStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(recentStore.state.isRecentlySignedIn == true)

        // Test old sign in (2 days ago)
        draft.lastSignedInDate = Date().addingTimeInterval(-86400 * 2)
        let oldStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            UserFormFeature.State(draft: draft)
        }) {
            UserFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }
        #expect(oldStore.state.isRecentlySignedIn == false)
    }
}