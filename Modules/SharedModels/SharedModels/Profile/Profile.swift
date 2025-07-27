import Foundation
import SharingGRDB


@Table("profile")
public struct Profile: Equatable, Identifiable, Sendable {
    public let id: Int
    public var membershipStatus: MembershipStatus
    public var authorizationStatus: AuthorizationStatus
    public var themeColorHex = 0x44a99ef_ff
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: Int = 0,
        membershipStatus: MembershipStatus,
        authorizationStatus: AuthorizationStatus,
        themeColorHex: Int = 0x44a99ef_ff,
        createdAt: Date? = Date(),
        updatedAt: Date? = nil
    ){
        self.id = id
        self.membershipStatus = membershipStatus
        self.authorizationStatus = authorizationStatus
        self.themeColorHex = themeColorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Profile.Draft: Identifiable {}

// MARK: - Database Relations
// Note: User owns Profile via profileID, no need for bidirectional relationship


public enum MembershipStatus: String, QueryBindable, CaseIterable {
    case free 
    case premium 
    case enterprise 

    public var displayName: String {
        rawValue.capitalized
    }

}

public enum AuthorizationStatus: String,  QueryBindable, CaseIterable {
    case authorized
    case guest
    case pending
    case restricted

    public var displayName: String {
        rawValue.capitalized
    }
}
