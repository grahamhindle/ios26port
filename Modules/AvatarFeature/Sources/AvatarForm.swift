import ComposableArchitecture
import Foundation
import DatabaseModule
import SharingGRDB
import SwiftUI
import UIComponents

@Reducer
public struct AvatarFormFeature {
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
    public enum Action: BindableAction, Sendable {
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

public struct AvatarForm: View {

    @Bindable var store: StoreOf<AvatarFormFeature>
    @Environment(\.dismiss) var dismiss

    public init(store: StoreOf<AvatarFormFeature>) {
        self.store = store
    }

    public var body: some View {
            Form {
                Section {
                    // Side-by-side Image Layout
                    HStack(spacing: 24) {
                        ImagePickerButton(
                            imageURL: store.draft.thumbnailURL,
                            size: 85,
                            title: "Avatar",
                            subtitle: "Main image",
                            action: { store.send(.showImagePicker(.thumbnail)) }
                        )

                        ImagePickerButton(
                            imageURL: store.draft.profileImageURL,
                            size: 85,
                            title: "Thumbnail",
                            subtitle: "Detail view",
                            action: { store.send(.showImagePicker(.profileImage)) }
                        )
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                } header: {
                    Label("Images", systemImage: "photo.stack.fill")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Section {
                    // Editable Name
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.key.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter a name", text: $store.draft.name)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)

                    // Editable Subtitle
                    HStack(spacing: 12) {
                        Image(systemName: "text.quote")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Subtitle")
                                .font(.caption)
                                .fontWeight(.medium)
                            TextField(
                                "Optional subtitle",
                                text: Binding(
                                    get: { store.draft.subtitle ?? "" },
                                    set: { store.send(.subtitleChanged($0)) }
                                )
                            )
                            .textInputAutocapitalization(.sentences)
                            .disableAutocorrection(true)
                            .font(.caption2)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)
                } header: {
                    Label("Details", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Section {
                    Picker("Category", selection: $store.draft.promptCategory) {
                        Text("Select Category").tag(PromptCategory?.none)
                        ForEach(PromptCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(PromptCategory?.some(category))
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Character Type", selection: $store.draft.promptCharacterType) {
                        Text("Select Type").tag(PromptCharacterType?.none)
                        ForEach(PromptCharacterType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(PromptCharacterType?.some(type))
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Mood", selection: $store.draft.promptCharacterMood) {
                        Text("Select Mood").tag(PromptCharacterMood?.none)
                        ForEach(PromptCharacterMood.allCases, id: \.self) { mood in
                            Text(mood.displayName).tag(PromptCharacterMood?.some(mood))
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Label("Prompt Character", systemImage: "slider.horizontal.3")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Section {
                    // Prompt Builder Button
                    Button(action: { store.send(.promptBuilderButtonTapped) }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.purple)
                            Text("Generate Claude Prompt")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)

                    // Display generated prompt if available
                    if let prompt = store.draft.generatedPrompt, !prompt.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.purple)
                                Text("Generated Prompt")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }

                            Text(prompt)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                } header: {
                    Label("Claude Prompt", systemImage: "brain.head.profile")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: store.draft.isPublic ? "globe" : "lock.fill")
                            .foregroundColor(store.draft.isPublic ? .green : .orange)
                            .frame(width: 20)

                        Toggle("Public Avatar", isOn: $store.draft.isPublic)
                            .toggleStyle(SwitchToggleStyle())

                        Spacer()

                        Text(store.draft.isPublic ? "Visible to all" : "Private")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                } header: {
                    Label("Visibility", systemImage: "eye.fill")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .formSectionSpacing()

            .sheet(isPresented: $store.showingImagePicker) {
                if let imagePickerType = store.imagePickerType {
                    ImageURLPicker(
                        selectedURL: Binding(
                            get: {
                                imagePickerType == .thumbnail
                                ? store.draft.thumbnailURL
                                : store.draft.profileImageURL
                            },
                            set: { url in
                                if imagePickerType == .thumbnail {
                                    store.send(.thumbnailURLSelected(url))
                                } else {
                                    store.send(.profileImageURLSelected(url))
                                }
                            }
                        ),
                        title: imagePickerType == .thumbnail ? "Select Thumbnail" : "Select Image"
                    )
                }
            }
            .sheet(store: store.scope(state: \.$promptBuilder, action: \.promptBuilder)) { promptBuilderStore in
                PromptBuilderView(store: promptBuilderStore)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelTapped)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveTapped)
                    }
                    .disabled(store.draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    }
            }
        }

    @ViewBuilder
    func imageSelectionRow(label: String, url: String?, buttonTitle: String,
                           action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                // Spacer()
                Button(buttonTitle, action: action)
            }
            Text(url ?? "No URL selected")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
}

// (Icon helper functions removed; using prompt-enum pickers instead)

#Preview("public") {
    // Set up dependencies BEFORE creating Store/State
    // swiftlint:disable redundant_discardable_let  
    let _ = prepareDependencies {
        // swiftlint:disable force_try
        $0.defaultDatabase = try! withDependencies {
            $0.context = .preview
        } operation: {
            try appDatabase()
        }
        $0.context = .preview
        // swiftlint:enable force_try
    }

    // Now create Store with properly initialized dependencies
    let store = Store(
        initialState: AvatarFormFeature.State(
                    draft: Avatar.Draft(
                        avatarId: "avatar_001",
                        name: "Business Professional",
                        subtitle: "Ready for meetings",
                        promptCategory: .business,
                        promptCharacterType: .professional,
                        promptCharacterMood: .helpful,
                        profileImageName: "avatar_business_man",
                        profileImageURL: "https://picsum.photos/600/600",
                        thumbnailURL: "https://picsum.photos/600/600",
                        userId: 1,
                        isPublic: true,
                        dateCreated: Date(),
                        dateModified: Date()
                    )
            )
        ) {
            AvatarFormFeature()
        }

    NavigationView {
        AvatarForm(store: store)
    }
}
