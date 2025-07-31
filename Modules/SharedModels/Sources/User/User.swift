import Foundation
import SharingGRDB
import OSLog
import SwiftUI

@Table("users")
public struct User: Equatable, Identifiable, Sendable {
    public let id: Int
    public var name: String = ""
    @Column("dateOfBirth")
    public var dateOfBirth: Date? = nil
    public var email: String? = nil
    @Column("dateCreated")
    public var dateCreated: Date?
    @Column("lastSignedInDate")
    public var lastSignedInDate: Date?

    // Merged from AuthenticationRecord
    public var authId: String? = nil
    public var isAuthenticated: Bool = false
    public var providerID: String? = nil
    
    // Merged from Profile
    public var membershipStatus: MembershipStatus = .free
    public var authorizationStatus: AuthorizationStatus = .guest
    public var themeColorHex: Int = 0x44a99ef_ff
    public var profileCreatedAt: Date? = nil
    public var profileUpdatedAt: Date? = nil

    public init(
        id: Int,
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


extension User.Draft: Identifiable, Sendable {}

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
            return 0x8E8E93FF // Gray
        case .premium:
            return 0x007AFFFF // Blue
        case .enterprise:
            return 0xFFD60AFF // Gold
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

// MARK: - Database Relations
// Note: Direct relationships, no foreign keys needed

