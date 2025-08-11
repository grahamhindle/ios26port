import Foundation
import SharingGRDB

@Table("message")
public struct Message: Equatable, Identifiable, Sendable {
    public let id: Int
    public let chatID: Chat.ID
    public var content: String
    public let timestamp: Date
    public let isFromUser: Bool
    public let createdAt: Date?

    public init(
        id: Int = 0,
        chatID: Chat.ID,
        content: String,
        timestamp: Date = Date(),
        isFromUser: Bool,
        createdAt: Date? = Date()
    ) {
        self.id = id
        self.chatID = chatID
        self.content = content
        self.timestamp = timestamp
        self.isFromUser = isFromUser
        self.createdAt = createdAt

    }
}

// MARK: - Database Relations
// Note: Relationships will be handled through queries rather than GRDB associations

// MARK: - Convenience Properties
extension Message {
    public var sender: String {
        isFromUser ? "User" : "Avatar"
    }

    public var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
