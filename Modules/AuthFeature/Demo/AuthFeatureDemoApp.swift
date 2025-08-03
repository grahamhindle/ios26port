import AuthFeature
import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI

// Configuration: Set to true to use Auth0, false for mock auth
private let useAuth0 = true

@main
struct AuthFeatureDemoApp: App {
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
            NavigationStack {
                AuthView(store: Store(initialState: AuthFeature.State()) {
                    AuthFeature()
                })
            }
            .navigationTitle("Auth Feature Demo")
        }
    }
}

// MARK: - Guest User Migration Demo
