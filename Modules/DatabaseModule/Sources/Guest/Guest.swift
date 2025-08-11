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
extension Guest {
    public var isExpired: Bool {
        Date() > expiresAt
    }

    public func extend(by hours: Int = 24) -> Guest {
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
