import Charts
import SharedModels
import SharingGRDB
import SwiftUI

public struct UserDetail: View {

    let row: UserModel.SelectedUsers

    @Dependency(\.defaultDatabase) var database

    public init(row: UserModel.SelectedUsers) {
        self.row = row

    }

    public var body: some View {

        List {
            HStack {
                Text("Name")
                Text(row.user.name ?? "")

            }
            HStack {
                Text("Authenticated:")
                Spacer()
                if let isAuthenticated = row.authRecord {

                    Image(systemName: isAuthenticated.isAuthenticated ? "checkmark.app.fill": "xmark.app.fill")
                }


                if let isProvider = row.authRecord?.providerID{
                    Text(isProvider )

                } else {
                    // ask to signup
                }
            }
        }

//        Text(isAuthenticated ? "Authenticated" : "Not Authenticated")
//        Text(tags.joined(separator: ", "))
//        Button("Details") {
//            onDetailsTapped()
//        }
    }
}

#Preview {
//    let _ = prepareDependencies {
//        $0.defaultDatabase = try! appDatabase()
//    }
//    
    NavigationView {
        Text("UserDetail Preview")
            .navigationTitle("User Detail")
    }
}




