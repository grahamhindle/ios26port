import Foundation
import SharingGRDB

@Table("tag")
public struct Tag: Equatable, Identifiable, Sendable {
    public let id: Int
    public var name: String
    public var color: String?
    public var category: String?
    public let dateCreated: Date?
    public let dateModified: Date?

    public init(
        id: Int = 0,
        name: String,
        color: String? = nil,
        category: String? = nil,
        dateCreated: Date? = Date(),
        dateModified: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.category = category
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

// MARK: - Database Relations

// Note: Relationships will be handled through queries rather than GRDB associations

@Table("avatarTag")
public struct AvatarTag: Equatable {
    public var avatarId: Avatar.ID
    public var tagId: Tag.ID
}
