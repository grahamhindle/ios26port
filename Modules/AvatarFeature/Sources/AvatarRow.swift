import SharedModels
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
                Text(avatar.name )
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
                } else if let characterOption = avatar.characterOption {
                    // Fallback for legacy records
                    Text(characterOption.displayName)
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
            AvatarRow(avatar: Avatar.mockAvatars[0])
            AvatarRow(avatar: Avatar.mockAvatars[1])
            AvatarRow(avatar: Avatar.mockAvatars[2])
        }
    }
}
