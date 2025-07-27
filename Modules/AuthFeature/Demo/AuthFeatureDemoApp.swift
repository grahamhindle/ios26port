import AuthFeature
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI

// Configuration: Set to true to use Auth0, false for mock auth
private let useAuth0 = true

@main
struct AuthFeatureDemoApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthInitView(model: AuthFeature())
        }
    }
}
