import AppFeature
import AuthFeature
import ComposableArchitecture
import SwiftUI
import DataService

// Configuration: Set to true to use live Auth0, false for mock auth
private let useLiveAuth = true

@main
struct AppFeatureDemoApp: App {
    init() {
        // Initialize database on app startup
        _ = UserRepositoryManager.forGuestUser()
        print("✅ Database initialized on app startup")
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                        .dependency(
                            \.authService,
                            useLiveAuth ? Auth0Client() as AuthProtocol : MockAuthClient() as AuthProtocol
                        )
                        .dependency(\.userRepositoryManager, UserRepositoryManager.forGuestUser())
                        ._printChanges()
                } withDependencies: {
                    $0.databaseCoordinator = (try? appDatabase(context: .live)) ?? DependencyValues.live.databaseCoordinator
                }
            )
        }
    }
}
