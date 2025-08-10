import AppFeature
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI

@main
struct AppFeatureDemoApp: App {
    init() {
        prepareDependencies {
            // swiftlint:disable force_try
            $0.defaultDatabase = try! appDatabase()
            // swiftlint:enable force_try
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AppView(store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                })
            }
        }
    }
}
