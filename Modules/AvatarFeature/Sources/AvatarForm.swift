import ComposableArchitecture
import DatabaseModule
import Foundation
import SharingGRDB

@Reducer
public struct AvatarFormFeature: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var draft: Avatar.Draft
        public var showingImagePicker = false
        @Presents var promptBuilder: PromptBuilderFeature.State?
        // swiftlint:disable nesting
        public enum ImagePickerType: Equatable, Sendable {
            case thumbnail
            case profileImage
        }
        // swiftlint:enable nesting

        var imagePickerType: ImagePickerType?

        public init(draft: Avatar.Draft) {
            self.draft = draft
        }
    }

    // Prefer deterministic mapping from PromptBuilder selections over free-text parsing
//    private func mapCharacterOption(from type: PromptCharacterType) -> CharacterOption? {
//        switch type {
//        case .expert, .professional, .specialist, .consultant, .advisor:
//            return .other
//        case .mentor, .teacher, .coach:
//            return .other
//        case .enthusiast:
//            return .other
//        case .ai, .custom:
//            return .other
//        }
//    }
//
//    private func mapCharacterAction(from category: PromptCategory, mood: PromptCharacterMood) -> CharacterAction? {
//        switch category {
//        case .codeReview, .debugging, .refactoring, .architecture, .testing, .optimization:
//            return .working
//        case .learning, .education, .academic, .research, .skillDevelopment:
//            return .studying
//        case .problemSolving, .business, .marketing, .sales, .finance, .projectManagement, .strategy,
//             .consulting, .entrepreneurship:
//            return .working
//        case .travel:
//            return .walking
//        case .food, .cooking:
//            return .eating
//        case .health, .fitness:
//            return .walking
//        case .writing, .design, .photography, .music, .art, .crafts, .creativity:
//            return .working
//        case .diy, .homeImprovement, .gardening:
//            return .working
//        case .communication, .relationships, .socialMedia, .networking, .publicSpeaking, .negotiation:
//            return .relaxing
//        case .science, .engineering, .dataAnalysis, .ai, .machineLearning, .cybersecurity, .blockchain:
//            return .working
//        case .general, .custom, .lifestyle, .personalDevelopment, .careerAdvice, .language:
//            // Use mood to refine a bit
//            switch mood {
//            case .friendly, .supportive, .creative:
//                return .relaxing
//            default:
//                return .working
//            }
//        }
//    }
//    
    // Title helpers
//    private func generateAvatarName(from draft: Avatar.Draft) -> String {
//        if let type = draft.promptCharacterType, let category = draft.promptCategory {
//            return "\(type.displayName) • \(category.displayName)"
//        }
//        if let option = draft.characterOption, let action = draft.characterAction {
//            return "\(option.displayName) • \(action.displayName)"
//        }
//        if let option = draft.characterOption { return option.displayName }
//        if let action = draft.characterAction { return action.displayName }
//        return "Untitled"
//    }
//
//    private func generateAvatarSubtitle(from draft: Avatar.Draft) -> String? {
//        if let mood = draft.promptCharacterMood {
//            return mood.displayName
//        }
//        return draft.subtitle
//    }

    private func generateAvatarName(from draft: Avatar.Draft) -> String {
        if let type = draft.promptCharacterType, let category = draft.promptCategory {
            return "\(type.displayName) • \(category.displayName)"
        }
        if let type = draft.promptCharacterType {
            return type.displayName
        }
        if let category = draft.promptCategory {
            return category.displayName
        }
        return draft.name.isEmpty ? "Untitled" : draft.name
    }

    private func generateAvatarSubtitle(from draft: Avatar.Draft) -> String? {
        draft.promptCharacterMood?.displayName
    }
    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case nameChanged(String)
        case subtitleChanged(String)
        case isPublicToggled(Bool)
        case showImagePicker(State.ImagePickerType)
        case hideImagePicker
        case thumbnailURLSelected(String?)
        case profileImageURLSelected(String?)
        case promptBuilderButtonTapped
        case promptBuilder(PresentationAction<PromptBuilderFeature.Action>)
        case saveTapped
        case cancelTapped
        case delegate(Delegate)
        // swiftlint:disable nesting
        public enum Delegate: Equatable, Sendable {
            case didFinish
            case didCancel
        }
    }
    // swiftlint:enable nesting

    @Dependency(\.defaultDatabase) var database

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.draft.name = name
                return .none

            case let .subtitleChanged(subtitle):
                state.draft.subtitle = subtitle.isEmpty ? nil : subtitle
                return .none

//            case let .characterOptionChanged(option):
//                state.draft.characterOption = option
//                return .none
//
//            case let .characterActionChanged(action):
//                state.draft.characterAction = action
//                return .none

            case let .isPublicToggled(isPublic):
                state.draft.isPublic = isPublic
                return .none

            case let .showImagePicker(type):
                state.imagePickerType = type
                state.showingImagePicker = true
                return .none

            case .hideImagePicker:
                state.showingImagePicker = false
                return .none

            case let .thumbnailURLSelected(url):
                state.draft.thumbnailURL = url
                state.showingImagePicker = false
                return .none

            case let .profileImageURLSelected(url):
                state.draft.profileImageURL = url
                state.showingImagePicker = false
                return .none

            case .promptBuilderButtonTapped:
                print("🎯 Prompt builder button tapped")
                state.promptBuilder = PromptBuilderFeature.State()
                return .none

            case .promptBuilder(.presented(.usePromptTapped)):
                if let promptBuilder = state.promptBuilder {
                    let prompt = promptBuilder.generatedPrompt
                    print("🎯 Using generated prompt: \(prompt)")
                    state.draft.generatedPrompt = prompt

                    // Deterministic mapping from PromptBuilder selections
//                    let mappedOption = mapCharacterOption(from: pb.selectedCharacterType)
//                    let mappedAction = mapCharacterAction(from: pb.selectedCategory, mood: pb.selectedCharacterMood)
//                    state.draft.characterOption = mappedOption
//                    state.draft.characterAction = mappedAction
                    // Persist prompt selections on the Avatar draft as well
                    state.draft.promptCategory = promptBuilder.selectedCategory
                    state.draft.promptCharacterType = promptBuilder.selectedCharacterType
                    state.draft.promptCharacterMood = promptBuilder.selectedCharacterMood
//                    print("🎯 Mapped from selections - Option: \(mappedOption?.displayName ?? "nil"), " +
//                          "Action: \(mappedAction?.displayName ?? "nil")")
//
//                    // Fallback to parsing if mapping produced nothing
//                    if mappedOption == nil || mappedAction == nil {
//                        updateCharacterDetailsFromPrompt(prompt: prompt,
//                                                       draft: &state.draft)
//                        print("🎯 Fallback parsed - Option: \(state.draft.characterOption?.displayName ?? "nil"), " +
//                              "Action: \(state.draft.characterAction?.displayName ?? "nil")")
//                    }
                }
                state.promptBuilder = nil
                return .none

            case .promptBuilder(.presented(.cancelTapped)):
                state.promptBuilder = nil
                return .none

            case .promptBuilder:
                return .none

            case .cancelTapped:
                return .send(.delegate(.didCancel))

            case .saveTapped:
                return .run { [draft = state.draft, database] send in
                    withErrorReporting {
                        try database.write { database in
                            try Avatar.upsert { draft }.execute(database)
                        }
                    }
                    await send(.delegate(.didFinish))
                }

            case .delegate:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$promptBuilder, action: \.promptBuilder) {
            PromptBuilderFeature()
        }
    }
}
