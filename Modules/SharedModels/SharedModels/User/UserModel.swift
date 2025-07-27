import OSLog
import SharingGRDB
import SwiftUI

@Observable
public final class UserModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database

    //   @ObservationIgnored
//    @FetchAll(User.order(by: \.name), animation: .default) public var users: [User] = []
//     @ObservationIgnored
//     @FetchAll(
//         User.order(by: \.name)
//            .leftJoin(AuthenticationRecord.all) {
//                $0.authenticationRecordID.eq($1.id)
//            }
//
//            .select { SelectedUsers.Columns(
//                authRecord: $1,
//                user: $0)
//            }
//
//     ) public var selectedUsersRows: [SelectedUsers] = []
    @ObservationIgnored
    @FetchAll(
        User.order(by: \.name)
            .leftJoin(AuthenticationRecord.all) {
                $0.authenticationRecordID.eq($1.id)
            }
            .leftJoin(Profile.all) {
                $0.profileID.eq($2.id)
            }

            .select {
                SelectedUsers.Columns(
                    authRecord: $1,
                    user: $0,
                    profile: $2
                )
            }
    ) public var userProfileAuth

    @Selection
    public struct SelectedUsers {
        public var authRecord: AuthenticationRecord?
        public var user: User
        public var profile: Profile?
    }

    public var searchText = ""

    public func addNewUser() -> (User.Draft, AuthenticationRecord.Draft?, Profile.Draft?) {
        let userDraft = User.Draft(
            name: "",
            email: ""
        )

        let authDraft = AuthenticationRecord.Draft(
            isAuthenticated: false,
            providerID: nil
        )

        let profileDraft = Profile.Draft(
            membershipStatus: .free,
            authorizationStatus: .guest,
            themeColorHex: 0xFF5733 // Default orange color without alpha
        )

        return (userDraft, authDraft, profileDraft)
    }

    public func deleteButtonTapped(user: User, auth: AuthenticationRecord?, profile: Profile?) {
        withErrorReporting {
            try database.write { db in
                if let auth = auth {
                    try AuthenticationRecord
                        .delete(auth)
                        .execute(db)
                }
                if let profile = profile {
                    try Profile
                        .delete(profile)
                        .execute(db)
                }
                try User
                    .delete(user)
                    .execute(db)
            }
        }
    }

    // MARK: - Individual Updates (Reusable)
    
    public func updateAuthenticationRecord(_ authRecord: AuthenticationRecord.Draft) async {
        await withErrorReporting {
            try await database.write { db in
                try AuthenticationRecord.upsert { authRecord }.execute(db)
            }
        }
    }

    public func updateProfile(_ profile: Profile.Draft) async {
        await withErrorReporting {
            try await database.write { db in
                try Profile.upsert { profile }.execute(db)
            }
        }
    }

    public func updateUser(_ user: User.Draft) async {
        await withErrorReporting {
            try await database.write { db in
                try User.upsert { user }.execute(db)
            }
        }
    }

    // MARK: - Full User Creation (Atomic)
    
    public func createUserWithRelations(_ user: User.Draft, authRecord: AuthenticationRecord.Draft?, profile: Profile.Draft?) async {
        await withErrorReporting {
            try await database.write { db in
                var authRecordID: Int? = nil
                var profileID: Int? = nil
                
                // 1. Save AuthRecord and Profile first (independent)
                if let authRecord = authRecord {
                    try AuthenticationRecord.upsert { authRecord }.execute(db)
                    authRecordID = (authRecord.id == nil || authRecord.id == 0) ? Int(db.lastInsertedRowID) : authRecord.id
                }
                
                if let profile = profile {
                    try Profile.upsert { profile }.execute(db)
                    profileID = (profile.id == nil || profile.id == 0) ? Int(db.lastInsertedRowID) : profile.id
                }
                
                // 2. Create User with foreign key references
                let finalUser = User.Draft(
                    id: user.id,
                    name: user.name,
                    dateOfBirth: user.dateOfBirth,
                    email: user.email,
                    dateCreated: user.dateCreated,
                    lastSignedInDate: user.lastSignedInDate,
                    authenticationRecordID: authRecordID,
                    profileID: profileID
                )
                
                try User.upsert { finalUser }.execute(db)
            }
            await updateQuery()
        }
    }

    public func updateQuery() async {
        await withErrorReporting {
            try await $userProfileAuth.load(
                User.order(by: \.name)
                    .leftJoin(AuthenticationRecord.all) {
                        $0.authenticationRecordID.eq($1.id)
                    }
                    .leftJoin(Profile.all) {
                        $0.profileID.eq($2.id)
                    }
                    .select {
                        SelectedUsers.Columns(
                            authRecord: $1,
                            user: $0,
                            profile: $2
                        )
                    },
                animation: .default
            )
        }
    }

    public init() {
        // Force the @FetchAll to execute immediately
        _ = userProfileAuth
    }
}
