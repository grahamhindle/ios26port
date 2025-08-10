import AppFeature
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI

@main
struct AppFeatureDemoApp: App {
    let store: StoreOf<AppFeature>
    init() {
        prepareDependencies {
            do {
                $0.defaultDatabase = try appDatabase()
                print("✅ Database initialized for AvatarFeature demo")
            } catch {
                fatalError("Database failed to initialize: \(error)")
            }
        }
        self.store = Store(initialState: AppFeature.State()){
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
