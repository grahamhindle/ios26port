import OSLog
import SharingGRDB
import SwiftUI

@MainActor
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
   @FetchAll(User.order(by: \.name), animation: .default) 
   public var users

    public var searchText = ""
    public var userForm: User.Draft?

   

    public func addUserButtonTapped() {
        userForm = User.Draft()
    }

    public func editButtonTapped(user: User) {
        userForm = User.Draft(user)
    }

    public func deleteButtonTapped(user: User) {
        withErrorReporting {
            try database.write { db in
                try User
                    .delete(user)
                    .execute(db)
            }
        }
    }

   
    public init(){}

}
