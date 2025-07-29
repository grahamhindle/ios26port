import AuthFeature
import ComposableArchitecture
import DataService
import OnboardingFeature
import SharedModels
import SharedResources
import SwiftUI
import TabBarFeature
import SharingGRDB

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var welcomeState: WelcomeFeature.State?
        public var authState: AuthFeature.State?
        public var onboardingState: OnboardingFeature.State?
        public var tabBarState: TabBarFeature.State?
        public var user: User?
        public var databaseContext: AppDatabaseContext = .live

        public init() {
            // Start with welcome screen
            welcomeState = .init()
        }
    }

    public enum Action {
        case onAppear
        case welcome(WelcomeFeature.Action)
        case auth(AuthFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case tabBar(TabBarFeature.Action)
        case switchDatabaseContext(AppDatabaseContext)
    }

    @Dependency(\.authService) var authService
    @Dependency(\.databases) var databases

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case let .welcome(.delegate(action)):
                switch action {
                case let .didAuthenticate(user):
                    // Authenticated user goes to TabBar
                    state.user = user
                    state.welcomeState = nil
                    state.tabBarState = .init()
                    // Switch to appropriate database context based on user type
                    let context: AppDatabaseContext = user.isAuthenticated ? .live : .guest
                    return .send(.switchDatabaseContext(context))

                case let .showOnboarding(user):
                    // Guest user goes to onboarding
                    state.user = user
                    state.welcomeState = nil
                    state.onboardingState = .init(user: user)
                    // Switch to guest database context for guest users
                    return .send(.switchDatabaseContext(.guest))

                case .showSignIn:
                    // Show sign-in screen
                    state.welcomeState = nil
                    state.authState = .init()
                    return .none
                }

            case let .auth(.delegate(action)):
                switch action {
                case let .didAuthenticate(user):
                    // After signing in, go to TabBar
                    state.user = user
                    state.authState = nil
                    state.tabBarState = .init()
                    // Switch to appropriate database context based on user type
                    let context: AppDatabaseContext = user.isAuthenticated ? .live : .guest
                    return .send(.switchDatabaseContext(context))
                case .didSignOut:
                    // Handle sign out - reset to live context for fresh start
                    state.user = nil
                    state.authState = nil
                    state.tabBarState = nil
                    state.welcomeState = .init()
                    return .send(.switchDatabaseContext(.live))
                case let .userCreated(user):
                    // Handle user creation
                    state.user = user
                    state.authState = nil
                    state.tabBarState = .init()
                    // Switch to appropriate database context based on user type
                    let context: AppDatabaseContext = user.isAuthenticated ? .live : .guest
                    return .send(.switchDatabaseContext(context))
                case let .userUpdated(user):
                    // Handle user update
                    state.user = user
                    return .none
                }

            case let .onboarding(.delegate(.complete(user, _))):
                state.onboardingState = nil
                state.user = user // Use the updated user from onboarding (in memory only)
                state.tabBarState = .init()

                // Update the in-memory user in AuthService so other features can access it
                return .run { _ in
                    @Dependency(\.authService) var authService
                    await authService.updateInMemoryUser(user)
                    print("✅ AppFeature: Updated in-memory guest user with theme: \(user.themeColorHex ?? "nil")")
                }

            case .tabBar(.delegate(.didSignOut)):
                print("🔍 AppFeature: TabBar signout detected, returning to welcome")
                // Return to welcome screen and reset to live context
                state.user = nil
                state.tabBarState = nil
                state.welcomeState = .init()
                return .send(.switchDatabaseContext(.live))

            case let .switchDatabaseContext(newContext):
                state.databaseContext = newContext
                return .run { _ in
                    if let database = databases[newContext] {
                        await withDependencies {
                            $0.defaultDatabase = database
                            $0.appDatabaseContext = newContext
                        } operation: {
                            // No additional actions needed - dependencies are switched
                        }
                        print("📱 AppFeature: Database context switched to: \(newContext)")
                    } else {
                        print("❌ AppFeature: No database found for context: \(newContext)")
                    }
                }
                
            case .welcome, .auth, .onboarding, .tabBar:
                return .none
            }
        }
        .ifLet(\.welcomeState, action: \.welcome) {
            WelcomeFeature()
        }
        .ifLet(\.authState, action: \.auth) {
            AuthFeature()
        }
        .ifLet(\.onboardingState, action: \.onboarding) {
            OnboardingFeature()
        }
        .ifLet(\.tabBarState, action: \.tabBar) {
            TabBarFeature()
        }
    }

    public init() {}
}

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let store = store.scope(state: \.welcomeState, action: \.welcome) {
                WelcomeView(store: store)
            } else if let store = store.scope(state: \.authState, action: \.auth) {
                AuthView(store: store)
            } else if let store = store.scope(state: \.onboardingState, action: \.onboarding) {
                OnboardingView(store: store)
            } else if let store = store.scope(state: \.tabBarState, action: \.tabBar) {
                TabBarView(store: store)
            } else {
                // Loading state while checking authentication
                ProgressView("Loading...")
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State()) {
        AppFeature()
    })
}
