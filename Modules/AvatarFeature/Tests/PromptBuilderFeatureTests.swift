import ComposableArchitecture
import CustomDump
import DatabaseModule
import DependenciesTestSupport
import Foundation
import Testing

@testable import AvatarFeature

@MainActor
struct PromptBuilderFeatureTests {
    static let fixedDate = Date(timeIntervalSince1970: 1_000_000)

    @Test func initialState() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Verify initial state
        #expect(store.state.selectedCategory == .general)
        #expect(store.state.selectedCharacterType == .expert)
        #expect(store.state.selectedCharacterMood == .helpful)
        #expect(store.state.customDescription.isEmpty)
        #expect(store.state.code.isEmpty)
        #expect(store.state.context.isEmpty)
        #expect(store.state.specificRequirements.isEmpty)
        #expect(store.state.newRequirement.isEmpty)
    }

    @Test func promptGeneration() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Test that generated prompt is not empty
        #expect(!store.state.generatedPrompt.isEmpty)
        #expect(store.state.generatedPrompt.contains("expert"))
        #expect(store.state.generatedPrompt.contains("helpful"))
    }

    @Test func categorySelection() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        await store.send(.binding(.set(\.selectedCategory, .codeReview))) {
            $0.selectedCategory = .codeReview
        }

        // Verify generated prompt updates with new category
        #expect(store.state.generatedPrompt.contains("code"))
    }

    @Test func characterTypeSelection() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        await store.send(.binding(.set(\.selectedCharacterType, .mentor))) {
            $0.selectedCharacterType = .mentor
        }

        // Verify generated prompt updates with new character type
        #expect(store.state.generatedPrompt.contains("mentor"))
    }

    @Test func moodSelection() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        await store.send(.binding(.set(\.selectedCharacterMood, .creative))) {
            $0.selectedCharacterMood = .creative
        }

        // Verify generated prompt updates with new mood
        #expect(store.state.generatedPrompt.contains("creative"))
    }

    @Test func customDescriptionInput() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        await store.send(.binding(.set(\.customDescription, "Help me debug this issue"))) {
            $0.customDescription = "Help me debug this issue"
        }

        // Verify custom description appears in generated prompt
        #expect(store.state.generatedPrompt.contains("Help me debug this issue"))
    }

    @Test func contextInput() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        await store.send(.binding(.set(\.context, "iOS Swift project"))) {
            $0.context = "iOS Swift project"
        }

        // Verify context appears in generated prompt
        #expect(store.state.generatedPrompt.contains("iOS Swift project"))
    }

    @Test func codeInput() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        let codeSnippet = "func test() { print(\"hello\") }"
        await store.send(.binding(.set(\.code, codeSnippet))) {
            $0.code = codeSnippet
        }

        // Verify code appears in generated prompt
        #expect(store.state.generatedPrompt.contains(codeSnippet))
    }

    @Test func requirementsManagement() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Add a requirement
        await store.send(.binding(.set(\.newRequirement, "Must be performant"))) {
            $0.newRequirement = "Must be performant"
        }

        await store.send(.addRequirementTapped) {
            $0.specificRequirements = ["Must be performant"]
            $0.newRequirement = ""
        }

        // Verify requirement appears in generated prompt
        #expect(store.state.generatedPrompt.contains("Must be performant"))

        // Add another requirement
        await store.send(.binding(.set(\.newRequirement, "Follow SOLID principles"))) {
            $0.newRequirement = "Follow SOLID principles"
        }

        await store.send(.addRequirementTapped) {
            $0.specificRequirements = ["Must be performant", "Follow SOLID principles"]
            $0.newRequirement = ""
        }

        // Remove a requirement
        await store.send(.removeRequirementTapped("Must be performant")) {
            $0.specificRequirements = ["Follow SOLID principles"]
        }

        #expect(store.state.specificRequirements == ["Follow SOLID principles"])
    }

    @Test func addEmptyRequirement() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Try to add empty requirement - should do nothing
        await store.send(.addRequirementTapped)

        #expect(store.state.specificRequirements.isEmpty)
        #expect(store.state.newRequirement.isEmpty)
    }

    @Test func actionHandling() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Test copy prompt action
        await store.send(.copyPromptTapped)

        // Test use prompt action
        await store.send(.usePromptTapped)

        // Test cancel action
        await store.send(.cancelTapped)
    }

    @Test func categorySpecificPrompts() async throws {
        let store = TestStore(initialState: PromptBuilderFeature.State()) {
            PromptBuilderFeature()
        }

        // Test code review category
        await store.send(.binding(.set(\.selectedCategory, .codeReview))) {
            $0.selectedCategory = .codeReview
        }
        #expect(store.state.generatedPrompt.contains("Performance issues"))
        #expect(store.state.generatedPrompt.contains("Security concerns"))

        // Test debugging category
        await store.send(.binding(.set(\.selectedCategory, .debugging))) {
            $0.selectedCategory = .debugging
        }
        #expect(store.state.generatedPrompt.contains("debugging"))
        #expect(store.state.generatedPrompt.contains("step by step"))

        // Test business category
        await store.send(.binding(.set(\.selectedCategory, .business))) {
            $0.selectedCategory = .business
        }
        #expect(store.state.generatedPrompt.contains("business"))
        #expect(store.state.generatedPrompt.contains("Strategy"))
    }

    @Test func complexPromptGeneration() async throws {
        var state = PromptBuilderFeature.State()
        state.selectedCategory = .codeReview
        state.selectedCharacterType = .mentor
        state.selectedCharacterMood = .supportive
        state.customDescription = "Review my Swift code for performance"
        state.context = "iOS app with complex UI"
        state.code = "class MyViewController: UIViewController { }"
        state.specificRequirements = ["Focus on memory leaks", "Check for retain cycles"]

        let store = TestStore(initialState: state) {
            PromptBuilderFeature()
        }

        let prompt = store.state.generatedPrompt

        // Verify all components are included
        #expect(prompt.contains("mentor"))
        #expect(prompt.contains("supportive"))
        #expect(prompt.contains("Review my Swift code for performance"))
        #expect(prompt.contains("iOS app with complex UI"))
        #expect(prompt.contains("class MyViewController"))
        #expect(prompt.contains("Focus on memory leaks"))
        #expect(prompt.contains("Check for retain cycles"))
        #expect(prompt.contains("Performance issues"))
    }
}
