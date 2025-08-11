import Foundation
import SharingGRDB

@Table("chat")
public struct Chat: Equatable, Identifiable, Sendable {
    public let id: Int
    public let userID: User.ID
    public let avatarID: Avatar.ID
    public var title: String?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: Int = 0,
        userID: User.ID,
        avatarID: Avatar.ID,
        title: String? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userID = userID
        self.avatarID = avatarID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt

    }
}

// MARK: - Database Relations
// Note: Relationships will be handled through queries rather than GRDB associations

// MARK: - Convenience Methods
extension Chat {
    public var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return "Chat with Avatar" // Will be enhanced with avatar name
    }
}
