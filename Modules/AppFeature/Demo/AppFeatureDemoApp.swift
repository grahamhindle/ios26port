import AppFeature
import ComposableArchitecture
import DatabaseModule
import SharingGRDB
import SwiftUI

@main
struct AppFeatureDemoApp: App {
  @Dependency(\.context) var context
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  init() {
    if context == .live {
      // swiftlint:enable force_try
      try! prepareDependencies {
        $0.defaultDatabase = try appDatabase()
        // swiftlint:disable force_try
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      if context == .live {
        NavigationStack {
          AppView(store: Self.store)
        }
      }
    }
  }
}
