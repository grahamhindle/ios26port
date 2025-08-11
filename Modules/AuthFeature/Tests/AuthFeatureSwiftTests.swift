@testable import AuthFeature
import ComposableArchitecture
import Testing

@MainActor
struct AuthFeatureTests {

    // MARK: - Initial State Tests

    @Test("Initial state should be guest with no loading")
    func initialState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        #expect(store.state.authenticationStatus == .guest)
        #expect(store.state.currentUserId == nil)
        #expect(store.state.isLoading == false)
        #expect(store.state.errorMessage == nil)
        #expect(store.state.authenticationResult == nil)
    }

    // MARK: - Loading State Tests

    @Test("setLoading should update loading state")
    func setLoading() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.setLoading(true)) {
            $0.isLoading = true
        }

        await store.send(.setLoading(false)) {
            $0.isLoading = false
        }
    }

    // MARK: - Guest Authentication Tests

    @Test("signInAsGuest should set guest status")
    func signInAsGuest() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.signInAsGuest) {
            $0.authenticationStatus = .guest
        }
    }

    // MARK: - Authentication Success Tests

    @Test("authenticationSucceeded should update state with user data")
    func authenticationSucceeded() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        let authId = "auth0|123456789"
        let provider = "auth0"
        let email = "test@example.com"

        await store.send(.authenticationSucceeded(authId: authId, provider: provider, email: email)) {
            $0.isLoading = false
            $0.authenticationStatus = .loggedIn
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: authId,
                provider: provider,
                isAuthenticated: true,
                email: email
            )
        }
    }

    @Test("authenticationSucceeded with empty authId should set guest status")
    func authenticationSucceededWithEmptyAuthId() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        await store.send(.authenticationSucceeded(authId: "", provider: nil, email: nil)) {
            $0.isLoading = false
            $0.authenticationStatus = .guest
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "",
                provider: nil,
                isAuthenticated: false,
                email: nil
            )
        }
    }

    // MARK: - Authentication Failure Tests

    @Test("authenticationFailed should update error state")
    func authenticationFailed() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        let error = AuthError.missingUserId

        await store.send(.authenticationFailed(error)) {
            $0.isLoading = false
            $0.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Clear Session Tests

    @Test("clearSession should prevent multiple concurrent calls")
    func clearSessionPreventsConcurrentCalls() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        // Should return .none when already loading
        await store.send(.clearSession)
    }

    @Test("clearSession should set loading state")
    func clearSessionSetsLoadingState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.clearSession) {
            $0.isLoading = true
        }

        // We can't easily test the async effects in this simple test,
        // but we can verify the initial state change
    }

    // MARK: - Sign In Tests

    @Test("signIn should prevent multiple concurrent calls")
    func signInPreventsConcurrentCalls() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        // Should return .none when already loading
        await store.send(.signIn)
    }

    @Test("signIn should set loading state")
    func signInSetsLoadingState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.signIn) {
            $0.isLoading = true
        }
    }

    // MARK: - Sign Up Tests

    @Test("signUp should prevent multiple concurrent calls")
    func signUpPreventsConcurrentCalls() async {
        var initialState = AuthFeature.State()
        initialState.isLoading = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        // Should return .none when already loading
        await store.send(.signUp)
    }

    @Test("signUp should set loading state")
    func signUpSetsLoadingState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.signUp) {
            $0.isLoading = true
        }
    }

    // MARK: - AuthenticationResult Tests

    @Test("AuthenticationResult should initialize correctly")
    func authenticationResultInitialization() {
        let result = AuthFeature.AuthenticationResult(
            authId: "test-id",
            provider: "test-provider",
            isAuthenticated: true,
            email: "test@example.com"
        )

        #expect(result.authId == "test-id")
        #expect(result.provider == "test-provider")
        #expect(result.isAuthenticated == true)
        #expect(result.email == "test@example.com")
    }

    // MARK: - AuthError Tests

    @Test("AuthError should have correct localized description")
    func authErrorLocalizedDescription() {
        let error = AuthError.missingUserId
        #expect(error.localizedDescription == "Authentication succeeded but user ID is missing")
    }
}

// MARK: - Integration Tests

@MainActor
struct AuthFeatureIntegrationTests {

    @Test("Complete authentication flow")
    func completeAuthenticationFlow() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Start with guest sign in
        await store.send(.signInAsGuest) {
            $0.authenticationStatus = .guest
        }

        // Then attempt sign up
        await store.send(.signUp) {
            $0.isLoading = true
        }

        // Simulate successful authentication
        await store.send(.authenticationSucceeded(
            authId: "auth0|123456",
            provider: "auth0",
            email: "user@example.com"
        )) {
            $0.isLoading = false
            $0.authenticationStatus = .loggedIn
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "auth0|123456",
                provider: "auth0",
                isAuthenticated: true,
                email: "user@example.com"
            )
        }
    }

    @Test("Authentication failure recovery")
    func authenticationFailureRecovery() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Start sign in
        await store.send(.signIn) {
            $0.isLoading = true
        }

        // Fail authentication
        let error = AuthError.missingUserId
        await store.send(.authenticationFailed(error)) {
            $0.isLoading = false
            $0.errorMessage = error.localizedDescription
        }

        // Clear error and try again
        await store.send(.setLoading(false)) {
            $0.isLoading = false
        }

        // Should be able to try again
        await store.send(.signUp) {
            $0.isLoading = true
        }
    }
}
