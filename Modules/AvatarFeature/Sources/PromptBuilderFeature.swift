import ComposableArchitecture
import Foundation
import SharedModels
import SwiftUI

@Reducer
public struct PromptBuilderFeature: Sendable {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var selectedCategory: PromptCategory = .general
        public var selectedCharacterType: PromptCharacterType = .expert
        public var selectedCharacterMood: PromptCharacterMood = .helpful
        public var customDescription = ""
        public var code = ""
        public var context = ""
        public var specificRequirements: [String] = []
        public var newRequirement = ""
        
        public var generatedPrompt: String {
            generatePrompt()
        }
        
        public init() {}
        
        private func generatePrompt() -> String {
            let characterType = selectedCharacterType.displayName.lowercased()
            let characterMood = selectedCharacterMood.description
            
            let characterIntro = """
            You are an expert \(characterType) with a \(characterMood) personality.
            
            """
            
            let categorySpecificPrompt = getCategorySpecificPrompt()
            
            let userInput = """
            **User Request**: \(customDescription.isEmpty ? "Please help me with this task" : customDescription)
            **Context**: \(context.isEmpty ? "General assistance needed" : context)
            **Code**: \(code.isEmpty ? "No code provided" : code)
            **Specific Requirements**: \(specificRequirements.isEmpty ? "None specified" : specificRequirements.joined(separator: ", "))
            
            """
            
            let closing = """
            Please provide a comprehensive response with:
            1. Clear explanations
            2. Code examples where applicable
            3. Best practices
            4. Step-by-step guidance if needed
            """
            
            return characterIntro + categorySpecificPrompt + userInput + closing
        }
        
        private func getCategorySpecificPrompt() -> String {
            switch selectedCategory {
            case .general:
                return getGeneralPrompt()
            case .codeReview:
                return getCodeReviewPrompt()
            case .debugging:
                return getDebuggingPrompt()
            case .refactoring:
                return getRefactoringPrompt()
            case .learning:
                return getLearningPrompt()
            case .problemSolving:
                return getProblemSolvingPrompt()
            case .architecture:
                return getArchitecturePrompt()
            case .testing:
                return getTestingPrompt()
            case .optimization:
                return getOptimizationPrompt()
            case .business:
                return getBusinessPrompt()
            case .travel:
                return getTravelPrompt()
            case .food:
                return getFoodPrompt()
            case .health:
                return getHealthPrompt()
            case .writing:
                return getWritingPrompt()
            case .design:
                return getDesignPrompt()
            case .diy:
                return getDiyPrompt()
            default:
                return getDefaultPrompt()
            }
        }
        
        private func getGeneralPrompt() -> String {
            """
            Please help me with the following request.
            
            """
        }
        
        private func getCodeReviewPrompt() -> String {
            """
            Please review this code for:
            - Performance issues
            - Security concerns
            - Best practices
            - Potential bugs
            - Architecture improvements
            
            """
        }
        
        private func getDebuggingPrompt() -> String {
            """
            I'm debugging an issue. Please help me solve this step by step.
            
            """
        }
        
        private func getRefactoringPrompt() -> String {
            """
            Please help me refactor this code to improve:
            - Readability
            - Maintainability
            - Performance
            - Architecture
            
            """
        }
        
        private func getLearningPrompt() -> String {
            """
            Please explain this concept in detail, suitable for learning and understanding.
            
            """
        }
        
        private func getProblemSolvingPrompt() -> String {
            """
            Please help me solve this problem with creative and effective solutions.
            
            """
        }
        
        private func getArchitecturePrompt() -> String {
            """
            Please help me design the architecture for this feature/system.
            
            """
        }
        
        private func getTestingPrompt() -> String {
            """
            Please help me create comprehensive tests for this code.
            
            """
        }
        
        private func getOptimizationPrompt() -> String {
            """
            Please help me optimize this code for better performance.
            
            """
        }
        
        private func getBusinessPrompt() -> String {
            """
            Please provide business insights and recommendations for:
            - Strategy
            - Analysis
            - Planning
            - Implementation
            
            """
        }
        
        private func getTravelPrompt() -> String {
            """
            Please help me plan and organize this travel request with:
            - Recommendations
            - Tips
            - Planning guidance
            - Cultural insights
            
            """
        }
        
        private func getFoodPrompt() -> String {
            """
            Please help me with culinary advice including:
            - Recipes
            - Techniques
            - Tips
            - Recommendations
            
            """
        }
        
        private func getHealthPrompt() -> String {
            """
            Please provide health and wellness guidance for:
            - General advice
            - Lifestyle recommendations
            - Best practices
            
            """
        }
        
        private func getWritingPrompt() -> String {
            """
            Please help me with writing including:
            - Structure
            - Style
            - Content
            - Editing suggestions
            
            """
        }
        
        private func getDesignPrompt() -> String {
            """
            Please help me with design including:
            - Principles
            - Best practices
            - Recommendations
            - Creative solutions
            
            """
        }
        
        private func getDiyPrompt() -> String {
            """
            Please help me with this DIY project including:
            - Materials needed
            - Step-by-step instructions
            - Safety tips
            - Alternative approaches
            
            """
        }
        
        private func getDefaultPrompt() -> String {
            """
            Please help me with this \(selectedCategory.displayName.lowercased()) request.
            
            """
        }
    }
    
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case addRequirementTapped
        case removeRequirementTapped(String)
        case copyPromptTapped
        case usePromptTapped
        case cancelTapped
    }
    
    public enum Delegate: Equatable {
        case didFinishWithPrompt(String)
        case didCancel
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .addRequirementTapped:
                if !state.newRequirement.isEmpty {
                    state.specificRequirements.append(state.newRequirement)
                    state.newRequirement = ""
                }
                return .none
                
            case let .removeRequirementTapped(requirement):
                state.specificRequirements.removeAll { $0 == requirement }
                return .none
                
            case .copyPromptTapped:
                // Copy to clipboard
                return .none
                
            case .usePromptTapped:
                return .none
                
            case .cancelTapped:
                return .none
            }
        }
    }
}

public struct PromptBuilderView: View {
    @Bindable var store: StoreOf<PromptBuilderFeature>
    
    public init(store: StoreOf<PromptBuilderFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            Form {
                // Compact character setup as menu chips in a single row
                Section("Character") {
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(PromptCategory.allCases, id: \.self) { category in
                                Button(category.displayName) { store.selectedCategory = category }
                            }
                        } label: {
                            Label(store.selectedCategory.displayName, systemImage: "square.grid.2x2")
                                .font(.footnote)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Menu {
                            ForEach(PromptCharacterType.allCases, id: \.self) { type in
                                Button(type.displayName) { store.selectedCharacterType = type }
                            }
                        } label: {
                            Label(store.selectedCharacterType.displayName, systemImage: "person")
                                .font(.footnote)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Menu {
                            ForEach(PromptCharacterMood.allCases, id: \.self) { mood in
                                Button(mood.displayName) { store.selectedCharacterMood = mood }
                            }
                        } label: {
                            Label(store.selectedCharacterMood.displayName, systemImage: "face.smiling")
                                .font(.footnote)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                // Keep request short; move advanced into a disclosure group
                Section("Request") {
                    TextField("Describe what you need help with", text: $store.customDescription, axis: .vertical)
                        .lineLimit(2...3)
                        .font(.footnote)

                    DisclosureGroup("More details") {
                        TextField("Context (optional)", text: $store.context, axis: .vertical)
                            .lineLimit(1...2)
                            .font(.footnote)

                        TextEditor(text: $store.code)
                            .frame(height: 80)
                            .font(.system(.footnote, design: .monospaced))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(store.specificRequirements, id: \.self) { requirement in
                                HStack {
                                    Text("• \(requirement)").font(.footnote)
                                    Spacer()
                                    Button("Remove") {
                                        store.send(.removeRequirementTapped(requirement))
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                }
                            }
                            HStack {
                                TextField("Add requirement", text: $store.newRequirement)
                                    .font(.footnote)
                                Button("Add") { store.send(.addRequirementTapped) }
                                    .font(.footnote)
                                    .disabled(store.newRequirement.isEmpty)
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                // Keep prompt visible
                Section("Generated Prompt") {
                    ScrollView {
                        Text(store.generatedPrompt)
                            .font(.system(.footnote, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(maxHeight: 220)
                }
            }
            .navigationTitle("Prompt Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Menu("Actions") {
                        Button("Copy") { store.send(.copyPromptTapped) }
                        Button("Use Prompt") { store.send(.usePromptTapped) }
                        Button("Save") { store.send(.usePromptTapped) }
                    }
                }
            }
        }
    }
} 