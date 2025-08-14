import Foundation
import SharingGRDB

@Table("tag")
public struct Tag: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var color: String?
    public var category: String?
    public let dateCreated: Date?
    public let dateModified: Date?

    public init(
        id: UUID = UUID(),
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

public extension Database {
    func createTagTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS tag (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            name TEXT NOT NULL,
            color TEXT,
            category TEXT,
            dateCreated TEXT,
            dateModified TEXT
            ) STRICT
            """)
    }
}
