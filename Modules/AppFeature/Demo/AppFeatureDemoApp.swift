import AppFeature
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI

@main
struct AppFeatureDemoApp: App {
    init() {
        let _ = prepareDependencies {
            // swiftlint:disable force_try
            let database = try! appDatabase()
            print("✅ Database created with prepareDependencies: \(type(of: database)) with path: \(database.path)")
            $0.defaultDatabase = database
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
