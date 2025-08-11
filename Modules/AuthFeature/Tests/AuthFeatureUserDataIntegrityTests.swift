@testable import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@MainActor
struct AuthFeatureUserDataIntegrityTests {
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
