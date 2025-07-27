import Foundation
import SharingGRDB

@Table("message_badge")
public struct MessageBadge: Equatable, Identifiable, Sendable {
    public let id: Int
    public let messageID: Message.ID
    public let badgeID: Badge.ID
    public let dateAdded: Date?
    
    public init(
        id: Int = 0,
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

// MARK: - Database Relations
// Note: Relationships will be handled through queries rather than GRDB associations