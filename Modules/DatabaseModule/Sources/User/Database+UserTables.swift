// This file contains extensions on GRDB.Database to modularize table creation for 'users' and 'avatar'.
import Foundation
import SharingGRDB
@Table("users")
public struct User: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name = ""
    @Column("dateOfBirth")
    public var dateOfBirth: Date?
    public var email: String?
    @Column("dateCreated")
    public var dateCreated: Date?
    @Column("lastSignedInDate")
    public var lastSignedInDate: Date?

    // Merged from AuthenticationRecord
    public var authId: String?
    public var isAuthenticated = false
    public var providerID: String?

    // Merged from Profile
    public var membershipStatus: MembershipStatus = .free
    public var authorizationStatus: AuthorizationStatus = .guest
    public var themeColorHex = 0x44a99ef_ff
    public var profileCreatedAt: Date?
    public var profileUpdatedAt: Date?

    public init(
        id: UUID,
        name: String,
        dateOfBirth: Date? = nil,
        email: String? = nil,
        dateCreated: Date? = nil,
        lastSignedInDate: Date? = nil,
        authId: String? = nil,
        isAuthenticated: Bool,
        providerID: String? = nil,
        membershipStatus: MembershipStatus,
        authorizationStatus: AuthorizationStatus,
        themeColorHex: Int,
        profileCreatedAt: Date? = nil,
        profileUpdatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.dateCreated = dateCreated
        self.lastSignedInDate = lastSignedInDate
        self.authId = authId
        self.isAuthenticated = isAuthenticated
        self.providerID = providerID
        self.membershipStatus = membershipStatus
        self.authorizationStatus = authorizationStatus
        self.themeColorHex = themeColorHex
        self.profileCreatedAt = profileCreatedAt
        self.profileUpdatedAt = profileUpdatedAt
    }
}

extension User.Draft: Equatable, Identifiable, Sendable {}

public extension Database {
    /// Creates the 'users' table if it doesn't exist.
    func createUsersTable() throws {
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                name TEXT NOT NULL,
                dateOfBirth TEXT,
                email TEXT,
                dateCreated TEXT,
                lastSignedInDate TEXT,
                authId TEXT,
                isAuthenticated INTEGER NOT NULL DEFAULT 0,
                providerID TEXT,
                membershipStatus TEXT NOT NULL DEFAULT 'free',
                authorizationStatus TEXT NOT NULL DEFAULT 'guest',
                themeColorHex INTEGER NOT NULL DEFAULT 0x44A99EFF,
                profileCreatedAt TEXT,
                profileUpdatedAt TEXT
            ) STRICT
            """
        ).execute(self)
    }
}

extension User.TableColumns: Sendable {

    public var isToday: some QueryExpression<Bool> {
        @Dependency(\.date.now) var now
        return #sql("coalesce(date(\(lastSignedInDate)) = date(\(now)), 0)")

    }
    public var isFree: some QueryExpression<Bool> {
        membershipStatus.eq(MembershipStatus.free)
    }
    public var isPremium: some QueryExpression<Bool> {
        membershipStatus.eq(MembershipStatus.premium)
    }
    public var isEnterprise: some QueryExpression<Bool> {
        membershipStatus.eq(MembershipStatus.enterprise)
    }
}

// MARK: - Enums moved from Profile

public enum MembershipStatus: String, QueryBindable, CaseIterable {
    case free
    case premium
    case enterprise

    public var displayName: String {
        rawValue.capitalized
    }

    public var color: Int {
        switch self {
        case .free:
            0x8E8E93FF // Gray
        case .premium:
            0x007AFFFF // Blue
        case .enterprise:
            0xFFD60AFF // Gold
        }
    }
}

public enum AuthorizationStatus: String, QueryBindable, CaseIterable {
    case authorized
    case guest
    case pending
    case restricted

    public var displayName: String {
        rawValue.capitalized
    }
}

