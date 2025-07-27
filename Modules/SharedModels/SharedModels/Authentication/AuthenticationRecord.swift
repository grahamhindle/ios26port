import Foundation
import SharingGRDB

@Table("authenticationRecord")
public struct AuthenticationRecord: Equatable, Identifiable, Sendable, Codable {
    public let id: Int
    public let authId: String?
    public let isAuthenticated: Bool
    public let providerID: String?
    
    // Relationship (populated through queries, not stored in database)

    
}

extension AuthenticationRecord.Draft: Identifiable {}

// MARK: - Database Relations
// Note: User owns AuthRecord via authenticationRecordID, no need for bidirectional relationship
