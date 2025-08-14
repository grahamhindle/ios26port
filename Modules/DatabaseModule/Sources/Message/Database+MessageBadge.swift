import Foundation
import SharingGRDB

@Table("message_badge")
public struct MessageBadge: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let messageID: Message.ID
    public let badgeID: Badge.ID
    public let dateAdded: Date?

    public init(
        id: UUID = UUID(),
        messageID: Message.ID,
        badgeID: Badge.ID,
        dateAdded: Date? = Date()
    ) {
        self.id = id
        self.messageID = messageID
        self.badgeID = badgeID
        self.dateAdded = dateAdded
    }
}

public extension Database {
    func createMessageBadgeTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS message_badge (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            messageID TEXT NOT NULL,
            badgeID TEXT NOT NULL,
            dateAdded TEXT,
            FOREIGN KEY (messageID) REFERENCES message(id) ON DELETE CASCADE,
            FOREIGN KEY (badgeID) REFERENCES badge(id) ON DELETE CASCADE,
            UNIQUE(messageID, badgeID)
            ) STRICT
            """)
    }
}
