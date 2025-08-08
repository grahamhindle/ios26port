import ComposableArchitecture
import SharedModels
import SharedResources
import SwiftUI
import UIComponents
import DataService

@Reducer
public struct WelcomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var imageLoader = ImageLoader.State()
        public var isLoading = false
        public var error: String?

        public init() {}
    }

    public struct WelcomeError: Error, Equatable {
        let message: String
    }

    public enum Action: Equatable {
        case delegate(Delegate)

        case onAppear
        case startTapped
        case loadRandomImage
        case loadPicsumImage
        case imageLoader(ImageLoader.Action)
        case signInTapped
        case authResponse(Result<User, WelcomeError>)
    }

    public enum Delegate: Equatable {
        case showSignIn
        case didAuthenticate(User)
        case showOnboarding(User) // Navigate to onboarding with guest user
    }

    public init() {}

    @Dependency(\.authService) var authService
    @Dependency(\.userRepositoryManager) var userRepositoryManager

    public var body: some ReducerOf<Self> {
        let authService = authService
        Scope(state: \.imageLoader, action: \.imageLoader) {
            ImageLoader()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadPicsumImage)

            case let .authResponse(.success(user)):
                state.isLoading = false
                // Route based on user type
                if !user.isAuthenticated {
                    // Guest users go to onboarding
                    return .send(.delegate(.showOnboarding(user)))
                } else {
                    // Authenticated users go to main app
                    return .send(.delegate(.didAuthenticate(user)))
                }

            case let .authResponse(.failure(error)):
                state.isLoading = false
                state.error = error.message
                return .none

            // already a authenticated user - check credentials, load user record, and check Auth0
            // load tabBarFeature with currentUser
            case .signInTapped:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let user = try await authService.signIn()
                        // now get user record
                        await send(.authResponse(.success(user)))
                        // now we go to TabBar, with explore as focus
                    } catch {
                        await send(.authResponse(.failure(WelcomeError(message: error.localizedDescription))))
                    }
                }

            // setup a new User, that is a guest account, stored in GuestUserRepository
            // setup as a shared user
            case .startTapped:
                state.isLoading = true
                state.error = nil

                return .run { [userRepositoryManager] send in
                    do {
                        // Create guest user using UserRepositoryManager
                        let guestUser = User(
                            id: nil,
                            userId: UUID().uuidString, // Generate unique guest ID
                            dateCreated: Date(),
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: false,
                            themeColorHex: nil,
                            email: nil,
                            displayName: "Guest User",
                            isEmailVerified: false,
                            isAuthenticated: false, // Guest users are not authenticated
                            providerID: "guest"
                        )

                        let createdUser = try await userRepositoryManager.createUser(guestUser)
                        await send(.authResponse(.success(createdUser)))
                        // now we go to Onboarding
                    } catch {
                        await send(.authResponse(.failure(WelcomeError(message: error.localizedDescription))))
                    }
                }

            case .loadPicsumImage:
                return .run { send in
                    if let url = ImageURLGenerator.randomPicsum() {
                        print("🔄 Loading test Picsumimage from: \(url)")
                        await send(.imageLoader(.loadImage(url)))
                    }
                }

            case .loadRandomImage:
                // Only load if not already loading or loaded
                switch state.imageLoader.loadingState {
                case .idle, .failed:
                    return .run { send in
                        if let url = await ImageURLGenerator.nextTestImage() {
                            print("🔄 Loading test image from: \(url)")
                            await send(.imageLoader(.loadImage(url)))
                        }
                    }
                default:
                    return .none
                }

            case .imageLoader:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

public struct WelcomeView: View {
    @Bindable var store: StoreOf<WelcomeFeature>

    public init(store: StoreOf<WelcomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                AsyncImageView(
                    store: store.scope(state: \.imageLoader, action: \.imageLoader)
                )
                .ignoresSafeArea()
                // .frame(height: 300)
                .task {
                    store.send(.onAppear)
                }

                VStack(spacing: SharedLayout.smallPadding) {
                    Text(SharedStrings.welcome)
                        .font(SharedFonts.largeTitle)
                        .fontWeight(.semibold)

                    Text(SharedStrings.youtube)
                        .font(SharedFonts.caption)
                        .foregroundStyle(SharedColors.secondary)
                }
                .padding(.top, SharedLayout.largePadding)

                VStack(spacing: SharedLayout.smallPadding) {
                    Text(SharedStrings.getStarted)
                        .anyButton(.callToAction) {
                            store.send(.startTapped)
                        }
                    Text(SharedStrings.alreadyHaveAnAccount)
                        .underline()
                        .font(SharedFonts.body)
                        .padding(SharedLayout.smallPadding)
                        .background(SharedColors.tappableBackground)
                        .onTapGesture {
                            store.send(.signInTapped)
                        }
                }
                .padding(SharedLayout.padding)
                HStack {
                    if let termsURL = URL(string: SharedURLStrings.termsOfService) {
                        Link(destination: termsURL) {
                            Text(SharedStrings.termsOfService)
                        }
                    }
                    if let privacyURL = URL(string: SharedURLStrings.privacyPolicy) {
                        Link(destination: privacyURL) {
                            Text(SharedStrings.privacyPolicy)
                        }
                    }
                }
            }
            .padding(SharedLayout.padding)
        }
    }
}

// #Preview {
//    WelcomeView(store: Store(initialState: WelcomeFeature.State()) {
//        WelcomeFeature()
//    })
// }
