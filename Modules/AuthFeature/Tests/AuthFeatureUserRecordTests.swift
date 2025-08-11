@testable import AuthFeature
import ComposableArchitecture
import Foundation
import DatabaseModule
import Testing

@MainActor
struct AuthFeatureUserRecordTests {
    // MARK: - User Record Creation Tests

    @Test("Email sign up creates complete User record")
    func emailSignUpCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // Set email and password first
        await store.send(.emailAuth(.emailChanged("test@example.com"))) {
            $0.emailAuth.email = "test@example.com"
        }

        await store.send(.emailAuth(.passwordChanged("password123"))) {
            $0.emailAuth.password = "password123"
        }

        await store.send(.emailAuth(.signUpTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
            $0.emailAuth.hasExistingAccount = false
            $0.emailAuth.isSignupMode = true
        }

        await store.skipReceivedActions()

        // Verify final state after all actions complete
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after sign up")
            return
        }
        #expect(!finalUser.id.isEmpty)
        #expect(finalUser.userId != nil)
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.isEmailVerified == true)
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")
        #expect(finalUser.dateCreated != nil)
        #expect(finalUser.lastSignedInDate != nil)
        #expect(finalUser.didCompleteOnboarding == false)
        #expect(finalUser.themeColorHex == nil)

        // Verify auth state is properly updated
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.error == nil)
        #expect(store.state.emailAuth.isLoading == false)
        #expect(store.state.emailAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == true)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

    @Test("Anonymous user with theme data upgrades to email account")
    func anonymousUserUpgradesToEmailAccount() async {
        // Create anonymous user with existing theme and onboarding data
        let anonymousUserWithData = User(
            databaseId: 100,
            userId: UUID().uuidString,
            dateCreated: Date().addingTimeInterval(-3600), // 1 hour ago
            lastSignedInDate: Date().addingTimeInterval(-300), // 5 minutes ago
            didCompleteOnboarding: true,
            themeColorHex: "#FF3855", // Poppy theme
            email: nil,
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: true,
            providerID: "anonymous"
        )

        let store = TestStore(initialState: AuthFeature.State(user: anonymousUserWithData)) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signInWithProvider: { _ in User.authenticatedMock },
                signUpWithProvider: { provider in
                    switch provider {
                    case let .email(email, _):
                        // Simulate preserving anonymous user data during signup
                        return User(
                            databaseId: anonymousUserWithData.databaseId,
                            userId: UUID().uuidString,
                            dateCreated: anonymousUserWithData.dateCreated,
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: anonymousUserWithData.didCompleteOnboarding,
                            themeColorHex: anonymousUserWithData.themeColorHex,
                            email: "user@example.com", // Use consistent email for testing
                            displayName: "Upgraded User",
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
                            databaseId: currentUser?.databaseId ?? 200,
                            userId: currentUser?.userId ?? UUID().uuidString,
                            dateCreated: currentUser?.dateCreated ?? Date(),
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: currentUser?.didCompleteOnboarding ?? false,
                            themeColorHex: currentUser?.themeColorHex,
                            email: "user@example.com", // Use consistent email for testing
                            displayName: "Upgraded User",
                            isEmailVerified: true,
                            isAnonymous: false,
                            providerID: "password"
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

        // Verify initial anonymous state
        #expect(store.state.user?.isAnonymous == true)
        #expect(store.state.user?.themeColorHex == "#FF3855")
        #expect(store.state.user?.didCompleteOnboarding == true)
        #expect(store.state.user?.email == nil)

        // Link with email account
        await store.send(.emailAuth(.signUpTapped)) {
            $0.hasExistingAccount = false
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
            $0.emailAuth.hasExistingAccount = false
            $0.emailAuth.isSignupMode = true
        }

        await store.skipReceivedActions()

        // Verify final state preserves anonymous user data but updates auth info
        guard let upgradedUser = store.state.user else {
            #expect(Bool(false), "User should exist after upgrade")
            return
        }

        // Verify authentication fields are updated
        #expect(upgradedUser.email == "user@example.com")
        #expect(upgradedUser.isEmailVerified == true)
        #expect(upgradedUser.isAnonymous == false)
        #expect(upgradedUser.providerID == "password")

        // Verify user data is preserved (this requires mock to simulate account linking)
        #expect(upgradedUser.themeColorHex == "#FF3855")
        #expect(upgradedUser.didCompleteOnboarding == true)
        #expect(upgradedUser.dateCreated != nil)

        // Verify final auth state
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.emailAuth.isLoading == false)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

    @Test("Email sign in creates complete User record")
    func emailSignInCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // Set email and password first
        await store.send(.emailAuth(.emailChanged("test@example.com"))) {
            $0.emailAuth.email = "test@example.com"
        }

        await store.send(.emailAuth(.passwordChanged("password123"))) {
            $0.emailAuth.password = "password123"
        }

        await store.send(.emailAuth(.signInTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
            $0.emailAuth.hasExistingAccount = false
            $0.emailAuth.isSignupMode = false
        }

        await store.skipReceivedActions()

        // Verify final state after all actions complete
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after sign in")
            return
        }
        #expect(!finalUser.id.isEmpty)
        #expect(finalUser.userId != nil)
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.displayName == "Mock User")
        #expect(finalUser.isEmailVerified == true)
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")
        #expect(finalUser.dateCreated != nil)
        #expect(finalUser.lastSignedInDate != nil)
        #expect(finalUser.didCompleteOnboarding == false)
        #expect(finalUser.themeColorHex == nil)

        // Verify auth state is properly updated
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.error == nil)
        #expect(store.state.emailAuth.isLoading == false)
        #expect(store.state.emailAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == true)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

    @Test("Anonymous sign in creates complete User record")
    func anonymousSignInCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        await store.send(.anonymousAuth(.signInAnonymouslyTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.anonymousAuth.isLoading = true
            $0.anonymousAuth.error = nil
        }

        await store.skipReceivedActions()

        // Verify final state after all actions complete
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after anonymous sign in")
            return
        }
        #expect(!finalUser.id.isEmpty)
        #expect(finalUser.userId != nil)
        #expect(finalUser.email == nil)
        #expect(finalUser.displayName == nil)
        #expect(finalUser.isEmailVerified == false)
        #expect(finalUser.isAnonymous == true)
        #expect(finalUser.providerID == "anonymous")
        #expect(finalUser.dateCreated == nil) // Anonymous mock has nil dates
        #expect(finalUser.lastSignedInDate == nil)
        #expect(finalUser.didCompleteOnboarding == nil)
        #expect(finalUser.themeColorHex == nil)

        // Verify auth state is properly updated
        #expect(store.state.hasExistingAccount == false)
        #expect(store.state.error == nil)
        #expect(store.state.anonymousAuth.isLoading == false)
        #expect(store.state.anonymousAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == false)
        #expect(store.state.emailAuth.isSignupMode == true)
    }

    @Test("Google Sign In creates complete User record")
    func googleSignInCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        await store.send(.googleAuth(.signInTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.googleAuth.isLoading = true
            $0.googleAuth.error = nil
        }

        await store.skipReceivedActions()

        // Verify final state after all actions complete
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after sign in")
            return
        }
        #expect(!finalUser.id.isEmpty)
        #expect(finalUser.userId != nil)
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.displayName == "Mock User")
        #expect(finalUser.isEmailVerified == true)
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")
        #expect(finalUser.dateCreated != nil)
        #expect(finalUser.lastSignedInDate != nil)
        #expect(finalUser.didCompleteOnboarding == false)
        #expect(finalUser.themeColorHex == nil)

        // Verify auth state is properly updated
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.error == nil)
        #expect(store.state.googleAuth.isLoading == false)
        #expect(store.state.googleAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == true)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

}
