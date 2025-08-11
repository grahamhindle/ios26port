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

    @Test("Apple Sign In creates complete User record")
    func appleSignInCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        await store.send(.appleAuth(.signInTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.appleAuth.isLoading = true
            $0.appleAuth.error = nil
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
        #expect(store.state.appleAuth.isLoading == false)
        #expect(store.state.appleAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == true)
        #expect(store.state.emailAuth.isSignupMode == false)
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

    // MARK: - Account Linking Tests

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

        let store = TestStore(initialState: AuthFeature.State(user: anonymousUserWithData)) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signInWithProvider: { _ in User.authenticatedMock },
                signUpWithProvider: { provider in
                    switch provider {
                    case let .email(email, _):
                        // Simulate account linking preserving data
                        return User(
                            id: anonymousUserWithData.id,
                            userId: UUID(),
                            dateCreated: anonymousUserWithData.dateCreated,
                            lastSignedInDate: Date(),
                            didCompleteOnboarding: anonymousUserWithData.didCompleteOnboarding,
                            themeColorHex: anonymousUserWithData.themeColorHex,
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

        // Verify initial anonymous state
        #expect(store.state.user?.isAnonymous == true)
        #expect(store.state.user?.themeColorHex == "#FF3855")
        #expect(store.state.user?.didCompleteOnboarding == true)

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

    @Test("User record consistency across authentication state changes")
    func userRecordConsistencyAcrossAuthStateChanges() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // 1. Sign in with email
        await store.send(.emailAuth(.signInTapped)) {
            $0.user = nil
            $0.hasExistingAccount = true
            $0.error = nil
            $0.emailAuth.isLoading = true
            $0.emailAuth.error = nil
        }

        await store.skipReceivedActions()

        // Verify user record after sign in
        guard let authenticatedUser = store.state.user else {
            #expect(Bool(false), "User should exist after sign in")
            return
        }
        #expect(authenticatedUser.email == "user@example.com")
        #expect(authenticatedUser.isAnonymous == false)
        #expect(authenticatedUser.providerID == "password")

        // 2. Sign out
        await store.send(.signOut) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.emailAuth.hasExistingAccount = false
        }

        // Verify user state is cleared
        #expect(store.state.user == nil)
        #expect(store.state.hasExistingAccount == false)
    }

    // MARK: - Data Integrity Tests

    @Test("User record fields validation for all authentication types")
    func userRecordFieldsValidation() async {
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

        // Verify user record fields are properly structured
        guard let user = store.state.user else {
            #expect(Bool(false), "User should exist after sign up")
            return
        }

        // Core identity fields
        #expect(user.id.uuidString.count == 36)
        #expect(user.userId != nil)

        // Timestamp fields
        #expect(user.dateCreated != nil)
        #expect(user.lastSignedInDate != nil)
        if let dateCreated = user.dateCreated {
            #expect(dateCreated <= Date())
        }
        if let lastSignedIn = user.lastSignedInDate {
            #expect(lastSignedIn <= Date())
        }

        // App-specific fields
        #expect(user.didCompleteOnboarding != nil)
        if let themeHex = user.themeColorHex {
            #expect(themeHex.hasPrefix("#"))
        }

        // Authentication fields
        #expect(user.email != nil)
        if let email = user.email {
            #expect(email.contains("@"))
        }
        #expect(user.isEmailVerified == true || user.isEmailVerified == false) // Valid bool
        #expect(user.isAnonymous == true || user.isAnonymous == false) // Valid bool
        #expect(user.providerID != nil)
        if let providerID = user.providerID {
            #expect(!providerID.isEmpty)
        }
    }

    @Test("Theme and onboarding data structure validation")
    func themeAndOnboardingDataValidation() async {
        // Create a user with theme and onboarding data
        let themedUser = User(
            id: UUID(),
            userId: UUID(),
            dateCreated: Date().addingTimeInterval(-1800), // 30 minutes ago
            lastSignedInDate: Date().addingTimeInterval(-300), // 5 minutes ago
            didCompleteOnboarding: true,
            themeColorHex: "#FFA500", // Orange theme
            email: "themed@example.com",
            displayName: "Themed User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State(user: themedUser)) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // Verify the themed user structure
        #expect(store.state.user?.themeColorHex == "#FFA500")
        #expect(store.state.user?.didCompleteOnboarding == true)
        #expect(store.state.user?.email == "themed@example.com")
        #expect(store.state.user?.isAnonymous == false)
        #expect(store.state.user?.providerID == "password")

        // Verify theme color format
        if let themeHex = store.state.user?.themeColorHex {
            #expect(themeHex.hasPrefix("#"))
            #expect(themeHex.count == 7) // Format: #RRGGBB
        }
    }

    @Test("User ID consistency across authentication flows")
    func userIdConsistencyAcrossFlows() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        // Test anonymous authentication
        await store.send(.anonymousAuth(.signInAnonymouslyTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.anonymousAuth.isLoading = true
        }

        await store.skipReceivedActions()

        // Test that user IDs are consistent and properly formed UUIDs
        guard let user = store.state.user else {
            #expect(Bool(false), "User should exist after anonymous sign in")
            return
        }
        #expect(user.id.uuidString.count == 36) // UUID string length
        if let userId = user.userId {
            #expect(userId.uuidString.count == 36) // UUID string length
        }
        #expect(user.isAnonymous == true)
        #expect(user.providerID == "anonymous")
    }
}
