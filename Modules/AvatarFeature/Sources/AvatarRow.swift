import DatabaseModule
import SwiftUI
import UIComponents

struct AvatarRow: View {
    var avatar: Avatar
    var resizingMode: ContentMode = .fill

    var body: some View {
        HStack {
            // Avatar image using AsyncImageView from UIComponents
            // AsyncImageView(
            //     avatarURL: URL(string: avatar.thumbnailURL ?? ""),
            //     size: 40
            // )
            AsyncImageView(url: URL(string: avatar.thumbnailURL ?? ""))
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(avatar.name)
                    .font(.headline)
                if let subtitle = avatar.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let category = avatar.promptCategory {
                    Text(category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let mood = avatar.promptCharacterMood {
                    Text(mood.displayName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

struct AvatarRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AvatarRow(avatar: Avatar(
                id: 1,
                avatarId: "preview_1",
                name: "Expert • Business",
                subtitle: "Helpful",
                promptCategory: .business,
                promptCharacterType: .expert,
                promptCharacterMood: .helpful,
                profileImageName: nil,
                profileImageURL: nil,
                thumbnailURL: nil,
                generatedPrompt: "",
                userId: 1,
                isPublic: true,
                dateCreated: Date(),
                dateModified: nil
            ))
            AvatarRow(avatar: Avatar(
                id: 2,
                avatarId: "preview_2",
                name: "Mentor • Design",
                subtitle: "Creative",
                promptCategory: .design,
                promptCharacterType: .mentor,
                promptCharacterMood: .creative,
                profileImageName: nil,
                profileImageURL: nil,
                thumbnailURL: nil,
                generatedPrompt: "",
                userId: 1,
                isPublic: true,
                dateCreated: Date(),
                dateModified: nil
            ))
        }
    }
}
