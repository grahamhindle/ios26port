import Foundation
import SharingGRDB

@Table("avatarTag")
public struct AvatarTag: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let avatarId: Avatar.ID
    public let tagId: Tag.ID
    public let dateAdded: Date?

    public init(
        id: UUID = UUID(),
        avatarId: Avatar.ID,
        tagId: Tag.ID,
        dateAdded: Date? = Date()
    ) {
        self.id = id
        self.avatarId = avatarId
        self.tagId = tagId
        self.dateAdded = dateAdded
    }
}

public extension Database {
    func createAvatarTagTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS avatarTag (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            avatarId TEXT NOT NULL ,
            tagId TEXT NOT NULL,
            FOREIGN KEY (avatarId) REFERENCES avatar(id) ON DELETE CASCADE,
            FOREIGN KEY (tagId) REFERENCES tag(id) ON DELETE CASCADE
            ) STRICT
            """)
    }
}
