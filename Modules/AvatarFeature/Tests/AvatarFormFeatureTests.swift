//
//  AvatarFormFeatureTests.swift
//  AvatarFeature
//
//  Created by Graham Hindle on 04/08/2025.
//

@testable import AvatarFeature
import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import DatabaseModule
import SharingGRDB
import SwiftUI
import Testing

@MainActor
struct AvatarFormFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)

    @Test func nameChanged() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.nameChanged("Test Avatar")) {
            $0.draft.name = "Test Avatar"
        }
    }

    @Test func subtitleChanged() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.subtitleChanged("Test Subtitle")) {
            $0.draft.subtitle = "Test Subtitle"
        }
    }

    @Test func characterOptionChanged() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.characterOptionChanged(.woman)) {
            $0.draft.characterOption = .woman
        }

        await store.send(.characterOptionChanged(.man)) {
            $0.draft.characterOption = .man
        }

        await store.send(.characterOptionChanged(nil)) {
            $0.draft.characterOption = nil
        }
    }

    @Test func characterActionChanged() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.characterActionChanged(.working)) {
            $0.draft.characterAction = .working
        }

        await store.send(.characterActionChanged(.studying)) {
            $0.draft.characterAction = .studying
        }

        await store.send(.characterActionChanged(nil)) {
            $0.draft.characterAction = nil
        }
    }

    @Test func characterLocationChanged() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.characterLocationChanged(.city)) {
            $0.draft.characterLocation = .city
        }

        await store.send(.characterLocationChanged(.park)) {
            $0.draft.characterLocation = .park
        }

        await store.send(.characterLocationChanged(nil)) {
            $0.draft.characterLocation = nil
        }
    }

    @Test func isPublicToggled() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        await store.send(.isPublicToggled(false)) {
            $0.draft.isPublic = false
        }

        await store.send(.isPublicToggled(true)) {
            $0.draft.isPublic = true
        }
    }

    @Test func imagePickerActions() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        // Test showing image picker for profile image
        await store.send(.showImagePicker(.profileImage)) {
            $0.imagePickerType = .profileImage
        }

        // Test hiding image picker
        await store.send(.hideImagePicker) {
            $0.imagePickerType = nil
        }

        // Test showing image picker for thumbnail
        await store.send(.showImagePicker(.thumbnail)) {
            $0.imagePickerType = .thumbnail
        }

        await store.send(.hideImagePicker) {
            $0.imagePickerType = nil
        }
    }

    @Test func imageURLSelection() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        // Test profile image URL selection
        await store.send(.profileImageURLSelected("https://example.com/profile.jpg")) {
            $0.draft.profileImageURL = "https://example.com/profile.jpg"
        }

        // Test thumbnail URL selection
        await store.send(.thumbnailURLSelected("https://example.com/thumb.jpg")) {
            $0.draft.thumbnailURL = "https://example.com/thumb.jpg"
        }

        // Test clearing URLs
        await store.send(.profileImageURLSelected(nil)) {
            $0.draft.profileImageURL = nil
        }

        await store.send(.thumbnailURLSelected(nil)) {
            $0.draft.thumbnailURL = nil
        }
    }

    @Test func saveTapped() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate
        let initialDraft = Avatar.Draft(
            name: "New Avatar",
            subtitle: "Test Avatar",
            userId: 1,
            isPublic: true
        )

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
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
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
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
        let initialDraft = Avatar.Draft(name: "Test", userId: 1, isPublic: true)

        let store = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: initialDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        // Test binding actions (if the state has @Bindable properties)
        await store.send(.binding(.set(\.draft.name, "Bound Name"))) {
            $0.draft.name = "Bound Name"
        }

        await store.send(.binding(.set(\.draft.subtitle, "Bound Subtitle"))) {
            $0.draft.subtitle = "Bound Subtitle"
        }
    }

    @Test func formValidation() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        // Test with empty name (should be invalid)
        var emptyNameDraft = Avatar.Draft(name: "", userId: 1, isPublic: true)
        let emptyNameStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: emptyNameDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        #expect(emptyNameStore.state.isValid == false)

        // Test with valid name
        var validDraft = Avatar.Draft(name: "Valid Name", userId: 1, isPublic: true)
        let validStore = TestStore(initialState: withDependencies({
            $0.date = .constant(fixedDate)
        }) {
            AvatarFormFeature.State(draft: validDraft)
        }) {
            AvatarFormFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database
            $0.context = .test
            $0.date = .constant(fixedDate)
        }

        #expect(validStore.state.isValid == true)
    }
}