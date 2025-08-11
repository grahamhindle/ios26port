@testable import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@MainActor
struct AuthFeatureAccountLinkingTests {
    @Test("Anonymous user account linking flow")
    func anonymousAccountLinkingFlow() async {
        // Start with anonymous user who has completed onboarding and selected theme
        let anonymousUserWithData = User(
            id: UUID(),
            userId: UUID(),
            dateCreated: Date().addingTimeInterval(-3600), // 1 hour ago
            lastSignedInDate: Date().addingTimeInterval(-3600),
            didCompleteOnboarding: true,
            themeColorHex: "#FF3855", // Poppy theme
            email: nil,
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: true,
            providerID: "anonymous"
        )

        let store = makeTestStore(with: anonymousUserWithData)

        verifyInitialAnonymousState(store: store)

        await performAccountLinking(store: store)

        await verifyFinalLinkedState(store: store)
    }

    // MARK: - Helper Functions

    private func makeTestStore(with user: User) -> TestStore<AuthFeature.State, AuthFeature.Action> {
        TestStore(initialState: AuthFeature.State(user: user)) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signInWithProvider: { _ in User.authenticatedMock },
                signUpWithProvider: { provider in
                    switch provider {
                    case let .email(email, _):
                        // Simulate account linking preserving data
                        return User(
                            id: user.id,
                            userId: UUID(),
                            dateCreated: user.dateCreated,
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: user.didCompleteOnboarding,
                            themeColorHex: user.themeColorHex,
                            email: "user@example.com",
                            displayName: "Linked User",
                            isEmailVerified: true,
                            isAnonymous: false,
                            providerID: "password"
                        )
                    default:
                        return User.authenticatedMock
                    }
                },
                linkAccountWithProvider: { _ in User.authenticatedMock },
                linkAccountWithProviderAndUserData: { provider, currentUser in
                    // Simulate proper account linking that preserves anonymous user data
                    switch provider {
                    case let .email(email, _):
                        return User(
                            id: currentUser?.id ?? UUID(), // Preserve original ID
                            userId: currentUser?.userId ?? UUID(), // Preserve original userId
                            dateCreated: currentUser?.dateCreated ?? Date(),
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: currentUser?.didCompleteOnboarding ?? false, // Preserve onboarding
                            themeColorHex: currentUser?.themeColorHex, // Preserve theme
                            email: email, // Use provider email
                            displayName: "Linked User",
                            isEmailVerified: true,
                            isAnonymous: false, // No longer anonymous
                            providerID: "password" // Use new provider
                        )
                    default:
                        return User.authenticatedMock
                    }
                },
                signIn: { _, _ in User.authenticatedMock },
                signUp: { _, _ in User.authenticatedMock },
                signInAnonymously: { User.anonymousMock },
                signInWithApple: { User.authenticatedMock },
                linkAccountWithEmail: { _, _ in User.authenticatedMock },
                linkAccountWithApple: { User.authenticatedMock },
                signOut: {},
                resetPassword: { _ in },
                authStateChanges: { AsyncStream { _ in } },
                currentUser: { nil },
                deleteAccount: {}
            )
        }
    }

    private func verifyInitialAnonymousState(store: TestStore<AuthFeature.State, AuthFeature.Action>) {
        #expect(store.state.user?.isAnonymous == true)
        #expect(store.state.user?.themeColorHex == "#FF3855")
        #expect(store.state.user?.didCompleteOnboarding == true)
    }

    private func performAccountLinking(store: TestStore<AuthFeature.State, AuthFeature.Action>) async {
        // Set email and password first
        await store.send(.emailAuth(EmailAuthFeature.Action.emailChanged("user@example.com"))) {
            $0.emailAuth.email = "user@example.com"
        }
        await store.send(.emailAuth(EmailAuthFeature.Action.passwordChanged("password123"))) {
            $0.emailAuth.password = "password123"
        }
        // Link with email account
        await store.send(.emailAuth(EmailAuthFeature.Action.signUpTapped)) {
            $0.hasExistingAccount = false
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
            $0.emailAuth.hasExistingAccount = false
            $0.emailAuth.isSignupMode = true
        }
        await store.skipReceivedActions()
    }

    private func verifyFinalLinkedState(store: TestStore<AuthFeature.State, AuthFeature.Action>) async {
        // Verify final state preserves data but updates auth
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after account linking")
            return
        }
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.isEmailVerified == true)
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")

        // Verify preserved data from anonymous account
        #expect(finalUser.themeColorHex == "#FF3855")
        #expect(finalUser.didCompleteOnboarding == true)
        #expect(finalUser.dateCreated != nil)

        // Verify auth state
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.emailAuth.isLoading == false)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

    // MARK: - User State Transition Tests
    @Test("Complete user journey: anonymous → email linking")
    func completeUserJourneyAnonymousToEmailLinking() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // 1. Start as anonymous user
        await store.send(.anonymousAuth(.signInAnonymouslyTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.anonymousAuth.isLoading = true
            $0.anonymousAuth.error = nil
        }

        await store.skipReceivedActions()

        // Verify anonymous state after first phase
        #expect(store.state.user?.isAnonymous == true)
        #expect(store.state.user?.providerID == "anonymous")
        #expect(store.state.user?.email == nil)
        #expect(store.state.hasExistingAccount == false)

        // 2. Set email and password, then link with email account
        await store.send(.emailAuth(.emailChanged("user@example.com"))) {
            $0.emailAuth.email = "user@example.com"
        }

        await store.send(.emailAuth(.passwordChanged("password123"))) {
            $0.emailAuth.password = "password123"
        }

        await store.send(.emailAuth(.signUpTapped)) {
            $0.hasExistingAccount = false
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
            $0.emailAuth.hasExistingAccount = false
            $0.emailAuth.isSignupMode = true
        }

        await store.skipReceivedActions()

        // Verify final authenticated state
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after complete journey")
            return
        }
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")
        #expect(finalUser.isEmailVerified == true)

        // Verify final auth state
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.emailAuth.isLoading == false)
        #expect(store.state.emailAuth.isSignupMode == false)
    }
}
