
import Charts
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI
import UIComponents

public struct AvatarForm: View {

    let store: StoreOf<AvatarFormFeature>

    @Environment(\.dismiss) var dismiss



    public init(store: StoreOf<AvatarFormFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    // Side-by-side Image Layout
                    HStack(spacing: 24) {
                        ImagePickerButton(
                            imageURL: viewStore.draft.thumbnailURL,
                            size: 85,
                            title: "Avatar",
                            subtitle: "Main image",
                            action: { viewStore.send(.showImagePicker(.thumbnail)) }
                        )
                        
                        ImagePickerButton(
                            imageURL: viewStore.draft.profileImageURL,
                            size: 85,
                            title: "Profile",
                            subtitle: "Detail view",
                            action: { viewStore.send(.showImagePicker(.profileImage)) }
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
                    // Display the generated name
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.key.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Avatar Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(viewStore.draft.name.isEmpty ? "Select character details below" : viewStore.draft.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)

                    // Display the generated subtitle
                    HStack(spacing: 12) {
                        Image(systemName: "text.quote")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Subtitle")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(viewStore.draft.subtitle?.isEmpty == false 
                                ? viewStore.draft.subtitle! 
                                : "Auto-generated from selections")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic(viewStore.draft.subtitle?.isEmpty != false)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                } header: {
                    Label("Auto-Generated", systemImage: "wand.and.stars")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Section {
                    PickerRow(
                        icon: "person.3.fill",
                        iconColor: .blue,
                        title: "Character Type",
                        selection: viewStore.binding(
                            get: \.draft.characterOption,
                            send: AvatarFormFeature.Action.characterOptionChanged
                        ),
                        options: CharacterOption.allCases,
                        getIcon: getCharacterIcon,
                        getDisplayName: { $0.displayName }
                    )

                    PickerRow(
                        icon: "figure.run",
                        iconColor: .green,
                        title: "Action",
                        selection: viewStore.binding(
                            get: \.draft.characterAction,
                            send: AvatarFormFeature.Action.characterActionChanged
                        ),
                        options: CharacterAction.allCases,
                        getIcon: getActionIcon,
                        getDisplayName: { $0.displayName }
                    )

                    PickerRow(
                        icon: "location.fill",
                        iconColor: .orange,
                        title: "Location",
                        selection: viewStore.binding(
                            get: \.draft.characterLocation,
                            send: AvatarFormFeature.Action.characterLocationChanged
                        ),
                        options: CharacterLocation.allCases,
                        getIcon: getLocationIcon,
                        getDisplayName: { $0.displayName }
                    )
                } header: {
                    Label("Character Details", systemImage: "slider.horizontal.3")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: viewStore.draft.isPublic ? "globe" : "lock.fill")
                            .foregroundColor(viewStore.draft.isPublic ? .green : .orange)
                            .frame(width: 20)
                        
                        Toggle("Public Avatar", isOn: viewStore.binding(
                            get: \.draft.isPublic,
                            send: AvatarFormFeature.Action.isPublicToggled
                        ))
                        .toggleStyle(SwitchToggleStyle())
                        
                        Spacer()
                        
                        Text(viewStore.draft.isPublic ? "Visible to all" : "Private")
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

            .sheet(isPresented: viewStore.binding(
                get: \.showingImagePicker,
                send: { _ in AvatarFormFeature.Action.hideImagePicker }
            )) {
                if let imagePickerType = viewStore.imagePickerType {
                    ImageURLPicker(
                        selectedURL: viewStore.binding(
                            get: { _ in
                                imagePickerType == .thumbnail
                                ? viewStore.draft.thumbnailURL
                                : viewStore.draft.profileImageURL
                            },
                            send: { url in
                                imagePickerType == .thumbnail
                                ? AvatarFormFeature.Action.thumbnailURLSelected(url)
                                : AvatarFormFeature.Action.profileImageURLSelected(url)
                            }
                        ),
                        title: imagePickerType == .thumbnail ? "Select Thumbnail" : "Select Image"
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewStore.send(.cancelTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewStore.send(.saveTapped)
                    }
                    .disabled(
                        viewStore.draft.characterOption == nil ||
                        viewStore.draft.characterAction == nil ||
                        viewStore.draft.characterLocation == nil
                    )
                }
            }
        }
    }

    @ViewBuilder
    func imageSelectionRow(label: String, url: String?, buttonTitle: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                //Spacer()
                Button(buttonTitle, action: action)
            }
            Text(url ?? "No URL selected")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
}

// MARK: - Form Row Components
extension AvatarForm {
    
    // MARK: - Icon Helpers
    private func getCharacterIcon(for option: CharacterOption) -> String {
        switch option {
        case .man: return "🧑"
        case .woman: return "👩"
        case .alien: return "👽"
        case .dog: return "🐕"
        case .cat: return "🐱"
        case .other: return "❓"
        }
    }
    
    private func getActionIcon(for action: CharacterAction) -> String {
        switch action {
        case .smiling: return "😊"
        case .sitting: return "🪑"
        case .eating: return "🍽️"
        case .drinking: return "🥤"
        case .walking: return "🚶"
        case .shopping: return "🛍️"
        case .studying: return "📚"
        case .working: return "💼"
        case .relaxing: return "🧘"
        case .fighting: return "⚔️"
        case .crying: return "😢"
        }
    }
    
    private func getLocationIcon(for location: CharacterLocation) -> String {
        switch location {
        case .city: return "🏙️"
        case .park: return "🌳"
        case .museum: return "🏛️"
        case .mall: return "🛍️"
        case .desert: return "🏜️"
        case .forest: return "🌲"
        case .space: return "🚀"
        }
    }
}

enum CharacterType: String, CaseIterable {
    case option = "Option"
    case action = "Action"
    case location = "location"


}

#Preview("public") {
    let _ = prepareDependencies {
        // swiftlint:disable force_try
        $0.defaultDatabase = try! appDatabase()
        // swiftlint:enable force_try
    }
    NavigationView {
        AvatarForm(store: Store(
            initialState: AvatarFormFeature.State(
                    draft: Avatar.Draft(
                        avatarId: "avatar_001",
                        name: "Business Professional",
                        subtitle: "Ready for meetings",
                        characterOption: CharacterOption.man,
                        characterAction: CharacterAction.working,
                        characterLocation: CharacterLocation.city,
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
        )
    }
}

// #Preview("private") {
//    _ = prepareDependencies {
//        // swiftlint:disable force_try
//        $0.defaultDatabase = try! appDatabase()
//        // swiftlint:enable force_try
//    }
//    NavigationView {
//        AvatarForm(avatar: Avatar.Draft(
//            avatarId: "avatar_001",
//            name: "Business Professional",
//            subtitle: "Ready for meetings",
//            characterOption: CharacterOption.man,
//            characterAction: CharacterAction.working,
//            characterLocation: CharacterLocation.city,
//            profileImageName: "avatar_business_man",
//            profileImageURL: "https://picsum.photos/600/600",
//            thumbnailURL: "https://picsum.photos/600/600",
//            userId: 1,
//            isPublic: true,
//            dateCreated: Date(),
//            dateModified: Date()
//        ))
//    }
// }
