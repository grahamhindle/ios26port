import Foundation
import SharingGRDB

@Table("guest")
public struct Guest: Equatable, Identifiable, Sendable {
    public let id: Int
    public let userID: User.ID
    public let sessionID: String
    public let expiresAt: Date
    public let createdAt: Date?

    public init(
        id: Int = 0,
        userID: User.ID,
        sessionID: String = UUID().uuidString,
        expiresAt: Date = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date(),
        createdAt: Date? = Date()
    ) {
        self.id = id
        self.userID = userID
        self.sessionID = sessionID
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }
}

//// MARK: - Database Relations
// extension Guest {
//    public static var user: BelongsTo<User> {
//        belongsTo(User.self, key: "userID")
//    }
// }

// MARK: - Convenience Methods

public extension Guest {
    var isExpired: Bool {
        Date() > expiresAt
    }

    func extend(by hours: Int = 24) -> Guest {
        let newExpiration = Calendar.current.date(byAdding: .hour, value: hours, to: Date()) ?? expiresAt
        return Guest(
            id: id,
            userID: userID,
            sessionID: sessionID,
            expiresAt: newExpiration,
            createdAt: createdAt
        )
    }
}

public extension Database {
    func createGuestTable() throws {
        try self.execute(sql: """
            CREATE TABLE IF NOT EXISTS guest (
            id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
            userID TEXT NOT NULL,
            sessionID TEXT NOT NULL UNIQUE,
            expiresAt TEXT NOT NULL,
            createdAt TEXT,
            FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE
            ) STRICT
            """)
    }
}
