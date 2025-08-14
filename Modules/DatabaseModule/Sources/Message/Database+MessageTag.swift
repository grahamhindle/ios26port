import Foundation
import SharingGRDB

@Table("message_tag")
public struct MessageTag: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let messageID: Message.ID
    public let tagID: Tag.ID
    public let dateAdded: Date?

    public init(
        id: UUID = UUID(),
        messageID: Message.ID,
        tagID: Tag.ID,
        dateAdded: Date? = Date()
    ) {
        self.id = id
        self.messageID = messageID
        self.tagID = tagID
        self.dateAdded = dateAdded
    }
}

public extension Database {
    func createMessageTagTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS message_tag (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            messageID TEXT NOT NULL,
            tagID TEXT NOT NULL,
            dateAdded TEXT,
            FOREIGN KEY (messageID) REFERENCES message(id) ON DELETE CASCADE,
            FOREIGN KEY (tagID) REFERENCES tag(id) ON DELETE CASCADE,
            UNIQUE(messageID, tagID)
            ) STRICT
            """)
    }
}
