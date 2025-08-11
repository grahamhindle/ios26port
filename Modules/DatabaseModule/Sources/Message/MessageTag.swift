import Foundation
import SharingGRDB

@Table("message_tag")
public struct MessageTag: Equatable, Identifiable, Sendable {
    public let id: Int
    public let messageID: Message.ID
    public let tagID: Tag.ID
    public let dateAdded: Date?

    public init(
        id: Int = 0,
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

// MARK: - Database Relations
// Note: Relationships will be handled through queries rather than GRDB associations
