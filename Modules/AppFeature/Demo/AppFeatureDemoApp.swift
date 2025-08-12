import AppFeature
import ComposableArchitecture
import DatabaseModule
import SharingGRDB
import SwiftUI

@main
struct AppFeatureDemoApp: App {
    let store: StoreOf<AppFeature>
    init() {
        prepareDependencies {
            do {
                $0.defaultDatabase = try withDependencies {
                    $0.context = .preview
                } operation: {
                    try appDatabase()
                }
                $0.context = .preview
                print("✅ Database initialized for AvatarFeature demo")
            } catch {
                fatalError("Database failed to initialize: \(error)")
            }
        }
        store = Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AppView(store: store)
            }
        }
    }
}
