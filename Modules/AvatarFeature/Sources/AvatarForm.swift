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

        // MARK: - Computed Properties

        /// Validates if the form is ready for submission
        public var isValid: Bool {
            !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        /// Generates display name from prompt selections or draft name
        public var displayName: String {
            generateAvatarName(from: draft)
        }

        /// Generates display subtitle from prompt selections or draft subtitle
        public var displaySubtitle: String? {
            generateAvatarSubtitle(from: draft)
        }

        public init(draft: Avatar.Draft) {
            self.draft = draft
        }

        // MARK: - Helper Methods

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
            draft.promptCharacterMood?.displayName ?? draft.subtitle
        }
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
                state.promptBuilder = PromptBuilderFeature.State()
                return .none

            case .promptBuilder(.presented(.usePromptTapped)):
                if let promptBuilder = state.promptBuilder {
                    let prompt = promptBuilder.generatedPrompt
                    state.draft.generatedPrompt = prompt

                    // Update draft with prompt builder selections
                    state.draft.promptCategory = promptBuilder.selectedCategory
                    state.draft.promptCharacterType = promptBuilder.selectedCharacterType
                    state.draft.promptCharacterMood = promptBuilder.selectedCharacterMood
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
