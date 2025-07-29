import Foundation
import SharingGRDB
import OSLog
import SwiftUI

@Table("users")
public struct User: Equatable, Identifiable, Sendable {
    public let id: Int
    public var name: String? = nil
    @Column("dateOfBirth")
    public var dateOfBirth: Date? = nil
    public var email: String? = nil
    @Column("dateCreated")
    public let dateCreated: Date?
    @Column("lastSignedInDate")
    public let lastSignedInDate: Date?

    // Foreign key IDs for relationships
    public let authenticationRecordID: AuthenticationRecord.ID?
    public let profileID: Profile.ID?
}

extension User.Draft: Identifiable, Sendable {}

// MARK: - Database Relations
// Note: Foreign key relationships handled manually in UserModel.saveUser()

