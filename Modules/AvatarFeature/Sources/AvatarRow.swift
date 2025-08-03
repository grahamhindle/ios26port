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

            VStack(alignment: .trailing) {
                if let characterOption = avatar.characterOption {
                    Text(characterOption.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(avatar.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {


    NavigationStack {
        AvatarRow(avatar: Avatar.mockAvatars[0])
        AvatarRow(avatar: Avatar.mockAvatars[1])
        AvatarRow(avatar: Avatar.mockAvatars[2])


    }
}
