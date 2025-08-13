//
//  AvatarFormFeatureTests.swift
//  AvatarFeature
//
//  Created by Graham Hindle on 04/08/2025.
//

@testable import AvatarFeature
import ComposableArchitecture
import CustomDump
import DatabaseModule
import DependenciesTestSupport
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

    @Test func promptBuilderIntegration() async throws {
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

        // Test opening prompt builder
        await store.send(.promptBuilderButtonTapped) {
            $0.promptBuilder = PromptBuilderFeature.State()
        }

        // Test using generated prompt
        await store.send(.promptBuilder(.presented(.usePromptTapped))) {
            if let promptBuilder = $0.promptBuilder {
                $0.draft.generatedPrompt = promptBuilder.generatedPrompt
                $0.draft.promptCategory = promptBuilder.selectedCategory
                $0.draft.promptCharacterType = promptBuilder.selectedCharacterType
                $0.draft.promptCharacterMood = promptBuilder.selectedCharacterMood
            }
            $0.promptBuilder = nil
        }
    }

    @Test func formValidationProperties() async throws {
        let database = try withDependencies {
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try prepareTestDatabase()
        }

        let fixedDate = Self.fixedDate

        // Test invalid form with empty name
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
        #expect(emptyNameStore.state.displayName == "Untitled")

        // Test valid form
        var validDraft = Avatar.Draft(
            name: "Test Avatar",
            promptCategory: .business,
            promptCharacterType: .professional,
            promptCharacterMood: .helpful,
            userId: 1,
            isPublic: true
        )
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
        #expect(validStore.state.displayName == "Professional • Business")
        #expect(validStore.state.displaySubtitle == "Helpful")
    }

    @Test func promptCategorySelection() async throws {
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

        // Test updating prompt category through binding
        await store.send(.binding(.set(\.draft.promptCategory, .codeReview))) {
            $0.draft.promptCategory = .codeReview
        }

        await store.send(.binding(.set(\.draft.promptCharacterType, .expert))) {
            $0.draft.promptCharacterType = .expert
        }

        await store.send(.binding(.set(\.draft.promptCharacterMood, .professional))) {
            $0.draft.promptCharacterMood = .professional
        }

        // Verify computed properties update
        #expect(store.state.displayName == "Expert • Code Review")
        #expect(store.state.displaySubtitle == "Professional")
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

    @Test func imagePickerIntegration() async throws {
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

        // Test showing image picker for thumbnail
        await store.send(.showImagePicker(.thumbnail)) {
            $0.imagePickerType = .thumbnail
            $0.showingImagePicker = true
        }

        // Test selecting thumbnail URL
        await store.send(.thumbnailURLSelected("https://example.com/thumb.jpg")) {
            $0.draft.thumbnailURL = "https://example.com/thumb.jpg"
            $0.showingImagePicker = false
        }

        // Test showing image picker for profile image
        await store.send(.showImagePicker(.profileImage)) {
            $0.imagePickerType = .profileImage
            $0.showingImagePicker = true
        }

        // Test hiding image picker
        await store.send(.hideImagePicker) {
            $0.showingImagePicker = false
        }
    }
}
