// AvatarFormFeature.swift
import Charts
import ComposableArchitecture
import Foundation
import SharedModels
import SharingGRDB

@Reducer
public struct AvatarFormFeature {
    // public typealias ImagePickerType = State.ImagePickerType
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        public var draft: Avatar.Draft
        public var showingImagePicker = false

            public enum ImagePickerType: Equatable, Sendable {
                case thumbnail
                case profileImage
            }
            var imagePickerType: ImagePickerType?

        public init(draft: Avatar.Draft) {
            self.draft = draft
        }

        mutating func updateGeneratedName() {
            guard let option = draft.characterOption,
                  let action = draft.characterAction,
                  let location = draft.characterLocation else { return }

            draft.name = generateAvatarName(option: option, action: action, location: location)
        }

        mutating func updateGeneratedSubtitle() {
            guard let action = draft.characterAction,
                  let location = draft.characterLocation else { 
                draft.subtitle = nil
                return 
            }

            draft.subtitle = generateAvatarSubtitle(action: action, location: location)
        }

        func generateAvatarName(
            option: CharacterOption,
            action: CharacterAction,
            location: CharacterLocation
        ) -> String {
            // Generate descriptive names based on combinations
            switch (option, action, location) {
            case (.man, .working, .city): return "Business Professional"
            case (.woman, .walking, .park): return "Casual Walker"
            case (.alien, .relaxing, .space): return "Space Explorer"
            case (.man, .studying, .museum): return "Scholar"
            case (.woman, .shopping, .mall): return "Shopper"
            case (.dog, .walking, .park): return "Park Walker"
            case (.cat, .relaxing, .city): return "City Cat"
            default: return "\(action.displayName) \(option.displayName)"
            }
        }

        func generateAvatarSubtitle(action: CharacterAction, location: CharacterLocation) -> String {
            // Generate contextual subtitles based on action and location
            switch (action, location) {
            case (.working, .city): return "Ready for meetings"
            case (.walking, .park): return "Enjoying the outdoors"
            case (.relaxing, .space): return "Boldly going where no one has gone before"
            case (.studying, .museum): return "Learning and exploring"
            case (.shopping, .mall): return "Finding the perfect items"
            case (.eating, .city): return "Savoring urban flavors"
            case (.drinking, .park): return "Refreshing in nature"
            case (.sitting, .museum): return "Contemplating art and history"
            case (.smiling, .city): return "Happy in the urban environment"
            case (.working, .desert): return "Working in challenging conditions"
            case (.relaxing, .forest): return "Finding peace in nature"
            case (.fighting, .city): return "Standing up for what's right"
            case (.crying, .park): return "Emotional moment in solitude"
            case (.walking, .forest): return "Exploring the wilderness"
            case (.studying, .city): return "Learning in the urban setting"
            case (.shopping, .city): return "City shopping adventure"
            default: return "\(action.displayName) in the \(location.displayName.lowercased())"
            }
        }
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case nameChanged(String)
        case subtitleChanged(String)
        case characterOptionChanged(CharacterOption?)
        case characterActionChanged(CharacterAction?)
        case characterLocationChanged(CharacterLocation?)
        case isPublicToggled(Bool)
        case showImagePicker(State.ImagePickerType)
        case hideImagePicker
        case thumbnailURLSelected(String?)
        case profileImageURLSelected(String?)
        case saveTapped
        case cancelTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case didFinish
            case didCancel
        }
    }

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

            case let .characterOptionChanged(option):
                state.draft.characterOption = option
                state.updateGeneratedName()
                state.updateGeneratedSubtitle()
                return .none

            case let .characterActionChanged(action):
                state.draft.characterAction = action
                state.updateGeneratedName()
                state.updateGeneratedSubtitle()
                return .none

            case let .characterLocationChanged(location):
                state.draft.characterLocation = location
                state.updateGeneratedName()
                state.updateGeneratedSubtitle()
                return .none

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

            case .cancelTapped:
                return .send(.delegate(.didCancel))

            case .saveTapped:
                return .run { [draft = state.draft] send in
                    @Dependency(\.defaultDatabase) var database
                    withErrorReporting {
                        try database.write { db in
                            try Avatar.upsert { draft }.execute(db)
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
    }
}
