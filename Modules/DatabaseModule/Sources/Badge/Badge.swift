import Foundation
import SharingGRDB

@Table("badge")
public struct Badge: Equatable, Identifiable, Sendable {
    public let id: Int
    public var name: String
    public var icon: String?
    public var color: String?
    public var description: String?
    public let dateCreated: Date?
    public let dateModified: Date?

    public init(
        id: Int = 0,
        name: String,
        icon: String? = nil,
        color: String? = nil,
        description: String? = nil,
        dateCreated: Date? = Date(),
        dateModified: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.description = description
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

// MARK: - Database Relations

// Note: Relationships will be handled through queries rather than GRDB associations
