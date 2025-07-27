import Foundation
import SharingGRDB
import OSLog
import SwiftUI

@Table("users")
public struct User: Equatable, Identifiable, Sendable {
    public let id: Int
    public var name: String = ""
    @Column("dateOfBirth")
    public var dateOfBirth: Date?
    public var email: String = ""
    @Column("dateCreated")
    public let dateCreated: Date?
    @Column("lastSignedInDate")
    public let lastSignedInDate: Date?

    // Foreign key IDs for relationships
    public let authenticationRecordID: AuthenticationRecord.ID?
    public let profileID: Profile.ID?
}

extension User.Draft: Identifiable {}

// MARK: - Database Relations
// Note: Foreign key relationships handled manually in UserModel.saveUser()

