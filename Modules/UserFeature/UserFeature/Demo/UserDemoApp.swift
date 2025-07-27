import SwiftUI
import SharedModels
import SharingGRDB
import UserFeature


@main
struct UserFeatureDemoApp: App {

    @Dependency(\.context) var context
      static let model = UserModel()

      init() {
        if context == .live {
          prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
          }
        }
      }

    var body: some Scene {
        WindowGroup {
            if context == .live {
                   NavigationStack {
                       UserView(model: Self.model)
                   }
                 }

        }
    }
}


