import SharedModels
import SharingGRDB
import SwiftUI
import UserFeature

@main
struct UserFeatureDemoApp: App {
  @Dependency(\.context) var context
  @Bindable static var userModel = UserModel(detailType: .all)

  init() {
    if context == .live {
      prepareDependencies {
        // swiftlint:disable force_try
        $0.defaultDatabase = try! appDatabase()
        // swiftlint:enable force_try
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      if context == .live {
        NavigationStack {
          UserView(model: Self.userModel)
        }
      }
    }
  }
}
