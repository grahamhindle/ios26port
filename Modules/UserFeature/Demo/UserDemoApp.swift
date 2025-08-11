import ComposableArchitecture
import DatabaseModule
import SharingGRDB
import SwiftUI
import UserFeature

@main
struct UserFeatureDemoApp: App {
  @Dependency(\.context) var context

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
          UserView(store: Store(initialState: UserFeature.State()) {
            UserFeature()
          })
        }
      }
    }
  }
}
