import Foundation
import SharingGRDB

@Table("message")
public struct Message: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let chatID: Chat.ID
    public var content: String
    public let timestamp: Date
    public let isFromUser: Bool
    public let createdAt: Date?

    public init(
        id: UUID ,
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

public extension Message {
    var sender: String {
        isFromUser ? "User" : "Avatar"
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}


public extension Database {
    func createMessageTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS message (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            chatID TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isFromUser INTEGER NOT NULL,
            createdAt TEXT,
            FOREIGN KEY (chatID) REFERENCES chat(id) ON DELETE CASCADE
            ) STRICT
            """)
    }
}
