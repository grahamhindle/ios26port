import Foundation
import SharingGRDB


@Table("chat")
public struct Chat: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let userID: User.ID
    public let avatarID: Avatar.ID
    public var title: String?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: UUID = UUID(),
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


public extension Database {
    func createChatTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS chat (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            userID TEXT NOT NULL,
            avatarID TEXT NOT NULL,
            title TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (avatarID) REFERENCES avatar(id) ON DELETE CASCADE
            ) STRICT
            """)
    }
}
