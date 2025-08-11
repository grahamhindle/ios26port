import SwiftUI
import SharedResources

// MARK: - Chat Message Cell View (Simple)

public struct ChatMessageCellView: View {
    public let messageId: String
    public let senderName: String?
    public let messageContent: String
    public let senderAvatar: String?
    public let timestamp: Date
    public let isFromCurrentUser: Bool
    public let messageType: MessageType
    public let deliveryStatus: DeliveryStatus
    public let reactions: [String]

    public enum MessageType: Equatable {
        case text
        case image
        case audio
        case video
        case file(String) // filename
        case location
    }

    public enum DeliveryStatus: Equatable {
        case sending
        case sent
        case delivered
        case read
        case failed
    }

    public init(
        messageId: String,
        senderName: String? = nil,
        messageContent: String,
        senderAvatar: String? = nil,
        timestamp: Date = Date(),
        isFromCurrentUser: Bool = false,
        messageType: MessageType = .text,
        deliveryStatus: DeliveryStatus = .sent,
        reactions: [String] = []
    ) {
        self.messageId = messageId
        self.senderName = senderName
        self.messageContent = messageContent
        self.senderAvatar = senderAvatar
        self.timestamp = timestamp
        self.isFromCurrentUser = isFromCurrentUser
        self.messageType = messageType
        self.deliveryStatus = deliveryStatus
        self.reactions = reactions
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isFromCurrentUser {
                // Sender avatar for incoming messages
                AsyncImageView(
                    avatarURL: URL(string: senderAvatar ?? ""),
                    size: 32
                )
            } else {
                Spacer()
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                MessageBubbleView(
                    content: messageContent,
                    messageType: messageType,
                    isFromCurrentUser: isFromCurrentUser
                )

                // Timestamp and delivery status
                HStack(spacing: 4) {
                    if isFromCurrentUser {
                        DeliveryStatusView(status: deliveryStatus)
                    }

                    Text(timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Reactions
                if !reactions.isEmpty {
                    ReactionsView(reactions: reactions)
                }
            }
            .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)

            if isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Views

private struct MessageBubbleView: View {
    let content: String
    let messageType: ChatMessageCellView.MessageType
    let isFromCurrentUser: Bool

    var body: some View {
        Group {
            switch messageType {
            case .text:
                Text(content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    )
                    .foregroundColor(isFromCurrentUser ? .white : .primary)

            case .image:
                ImageMessageView(content: content, isFromCurrentUser: isFromCurrentUser)

            case .location:
                LocationMessageView(content: content, isFromCurrentUser: isFromCurrentUser)

            case .audio:
                AudioMessageView(content: content, isFromCurrentUser: isFromCurrentUser)

            case .video:
                VideoMessageView(content: content, isFromCurrentUser: isFromCurrentUser)

            case .file(let filename):
                FileMessageView(content: content, filename: filename, isFromCurrentUser: isFromCurrentUser)
            }
        }
    }
}

private struct DeliveryStatusView: View {
    let status: ChatMessageCellView.DeliveryStatus

    var body: some View {
        Image(systemName: deliveryStatusIcon)
            .font(.caption2)
            .foregroundColor(deliveryStatusColor)
    }

    private var deliveryStatusIcon: String {
        switch status {
        case .sending:
            "clock"
        case .sent:
            "checkmark"
        case .delivered:
            "checkmark.circle"
        case .read:
            "checkmark.circle.fill"
        case .failed:
            "exclamationmark.circle"
        }
    }

    private var deliveryStatusColor: Color {
        switch status {
        case .sending:
            .orange
        case .sent, .delivered:
            .secondary
        case .read:
            .blue
        case .failed:
            .red
        }
    }
}

private struct ReactionsView: View {
    let reactions: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(reactions, id: \.self) { reaction in
                Text(reaction)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
}

private struct ImageMessageView: View {
    let content: String
    let isFromCurrentUser: Bool

    var body: some View {
        AsyncImageView(
            url: URL(string: content),
            width: 200,
            height: 150,
            cornerRadius: 12,
            contentMode: .fit,
            placeholderImage: "photo"
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFromCurrentUser ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

private struct LocationMessageView: View {
    let content: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(isFromCurrentUser ? .white : .blue)
            Text("Location")
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
        )
        .foregroundColor(isFromCurrentUser ? .white : .primary)
    }
}

private struct AudioMessageView: View {
    let content: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            Image(systemName: "mic.fill")
                .foregroundColor(isFromCurrentUser ? .white : .blue)
            Text("Audio Message")
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
        )
        .foregroundColor(isFromCurrentUser ? .white : .primary)
    }
}

private struct VideoMessageView: View {
    let content: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            Image(systemName: "video.fill")
                .foregroundColor(isFromCurrentUser ? .white : .blue)
            Text("Video Message")
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
        )
        .foregroundColor(isFromCurrentUser ? .white : .primary)
    }
}

private struct FileMessageView: View {
    let content: String
    let filename: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(isFromCurrentUser ? .white : .blue)
            Text(filename)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
        )
        .foregroundColor(isFromCurrentUser ? .white : .primary)
    }
}

// MARK: - Preview

#Preview("Chat Messages") {
    VStack(spacing: 16) {
        ChatMessageCellView(
            messageId: "1",
            senderName: "John",
            messageContent: "Hey there! How are you doing?",
            senderAvatar: "https://picsum.photos/32/32?random=1",
            isFromCurrentUser: false,
            deliveryStatus: .read
        )

        ChatMessageCellView(
            messageId: "2",
            senderName: "Me",
            messageContent: "I'm doing great, thanks for asking!",
            isFromCurrentUser: true,
            deliveryStatus: .delivered
        )

        ChatMessageCellView(
            messageId: "3",
            senderName: "John",
            messageContent: "https://picsum.photos/200/150?random=2",
            senderAvatar: "https://picsum.photos/32/32?random=1",
            isFromCurrentUser: false,
            messageType: .image,
            reactions: ["👍", "❤️"]
        )

        ChatMessageCellView(
            messageId: "4",
            senderName: "Me",
            messageContent: "Current Location",
            isFromCurrentUser: true,
            messageType: .location,
            deliveryStatus: .sending
        )
    }
    .padding()
}
