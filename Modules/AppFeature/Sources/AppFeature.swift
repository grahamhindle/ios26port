import ComposableArchitecture
import DatabaseModule
import SharedResources
import SharingGRDB
import SwiftUI
import TabBarFeature
import WelcomeFeature

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var welcomeState: WelcomeFeature.State?
        public var tabBarState: TabBarFeature.State?
        public var user: User?

        public init() {
            // Start with welcome screen
            welcomeState = .init()
        }
    }

    public enum Action {
        case onAppear
        case welcome(WelcomeFeature.Action)
        case tabBar(TabBarFeature.Action)
    }

    public init() {}

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
                    state.tabBarState = .init(user: user)
                    return .none

                case let .showOnboarding(user):
                    // Guest user goes to onboarding
                    state.user = user
                    state.welcomeState = nil
                    // For now, go directly to TabBar until OnboardingFeature is implemented
                    state.tabBarState = .init(user: user)
                    return .none

                case .showSignIn:
                    // Auth0 universal login is handled within WelcomeFeature
                    // No separate auth screen needed
                    return .none
                }

            // case let .onboarding(.delegate(.complete(user, _))):
            //     state.onboardingState = nil
            //     state.user = user // Use the updated user from onboarding (in memory only)
            //     state.tabBarState = .init()

            //     // Update the in-memory user in AuthService so other features can access it
            //     return .run { _ in
            //         @Dependency(\.authService) var authService
            //         await authService.updateInMemoryUser(user)
            //         print("✅ AppFeature: Updated in-memory guest user with theme: \(user.themeColorHex ?? "nil")")
            //     }

            case .tabBar(.delegate(.didSignOut)):
                print("🔍 AppFeature: TabBar signout detected, returning to welcome")
                // Return to welcome screen and reset to live context
                state.user = nil
                state.tabBarState = nil
                state.welcomeState = .init()
                // return .send(.switchDatabaseContext(.live))
                return .none

            case .welcome, .tabBar:
                return .none
            }
        }
        .ifLet(\.welcomeState, action: \.welcome) {
            WelcomeFeature()
        }
        .ifLet(\.tabBarState, action: \.tabBar) {
            TabBarFeature()
        }
    }
}
