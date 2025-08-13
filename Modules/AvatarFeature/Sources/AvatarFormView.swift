import ComposableArchitecture
import SharingGRDB
import SwiftUI
import UIComponents
import DatabaseModule

public struct AvatarForm: View {
    @Bindable var store: StoreOf<AvatarFormFeature>
    @Environment(\.dismiss) var dismiss

    public init(store: StoreOf<AvatarFormFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            ImageSelectionSection(store: store)
            DetailsSection(store: store)
            PromptCharacterSection(store: store)
            PromptBuilderSection(store: store)
            VisibilitySection(store: store)
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
}

private struct ImageSelectionSection: View {
    @Bindable var store: StoreOf<AvatarFormFeature>

    var body: some View {
        Section {
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
    }
}

private struct DetailsSection: View {
    @Bindable var store: StoreOf<AvatarFormFeature>

    var body: some View {
        Section {
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
    }
}

private struct PromptCharacterSection: View {
    @Bindable var store: StoreOf<AvatarFormFeature>

    var body: some View {
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
    }
}

private struct PromptBuilderSection: View {
    @Bindable var store: StoreOf<AvatarFormFeature>

    var body: some View {
        Section {
            Button(
                action: { store.send(.promptBuilderButtonTapped) },
                label: {
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
            )
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)

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
    }
}

private struct VisibilitySection: View {
    @Bindable var store: StoreOf<AvatarFormFeature>

    var body: some View {
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
}

#Preview("public") {
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
