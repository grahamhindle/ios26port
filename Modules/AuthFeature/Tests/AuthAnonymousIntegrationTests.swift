@testable import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import Testing

@Suite("Auth Feature Anonymous Integration Tests", .serialized)
@MainActor
struct AuthAnonymousIntegrationTests {
    @Test("Anonymous sign in success through AuthFeature")
    func anonymousSignInSuccessThroughAuthFeature() async {
        let mockUser = User(
            uid: "anonymous-uid",
            email: nil,
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: true,
            providerID: "anonymous"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signIn: { _, _ in throw TestError.notImplemented },
                signUp: { _, _ in throw TestError.notImplemented },
                signInAnonymously: { mockUser },
                signInWithApple: { throw TestError.notImplemented },
                signOut: {},
                resetPassword: { _ in },
                authStateChanges: { AsyncStream { _ in } },
                currentUser: { nil },
                deleteAccount: {},
                linkAccountWithEmail: { _, _ in throw TestError.notImplemented },
                linkAccountWithApple: { throw TestError.notImplemented }
            )
        }

        // Test that initial state is correct
        #expect(store.state.user == nil)
        #expect(store.state.anonymousAuth.isLoading == false)
        #expect(store.state.anonymousAuth.error == nil)

        // Send anonymous sign in action
        await store.send(.anonymousAuth(.signInAnonymouslyTapped)) {
            $0.anonymousAuth.isLoading = true
            $0.anonymousAuth.error = nil
        }

        // Expect response action
        await store.receive(.anonymousAuth(.signInResponse(.success(mockUser)))) {
            $0.anonymousAuth.isLoading = false
        }

        // Expect delegate action to be sent
        await store.receive(.anonymousAuth(.delegate(.didAuthenticate(mockUser))))

        // Verify that the user is set in the main AuthFeature state
        #expect(store.state.user == mockUser)
        #expect(store.state.error == nil)
    }

    @Test("Anonymous sign in failure through AuthFeature")
    func anonymousSignInFailureThroughAuthFeature() async {
        let expectedError = TestError.signInFailed

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signIn: { _, _ in throw TestError.notImplemented },
                signUp: { _, _ in throw TestError.notImplemented },
                signInAnonymously: { throw expectedError },
                signInWithApple: { throw TestError.notImplemented },
                signOut: {},
                resetPassword: { _ in },
                authStateChanges: { AsyncStream { _ in } },
                currentUser: { nil },
                deleteAccount: {},
                linkAccountWithEmail: { _, _ in throw TestError.notImplemented },
                linkAccountWithApple: { throw TestError.notImplemented }
            )
        }

        // Send anonymous sign in action
        await store.send(.anonymousAuth(.signInAnonymouslyTapped)) {
            $0.anonymousAuth.isLoading = true
            $0.anonymousAuth.error = nil
        }

        // Expect failure response
        await store.receive(.anonymousAuth(.signInResponse(.failure(.unknown(expectedError.localizedDescription))))) {
            $0.anonymousAuth.isLoading = false
            $0.anonymousAuth.error = expectedError.localizedDescription
        }

        // Verify that user is still nil and error is not set in main state
        #expect(store.state.user == nil)
        #expect(store.state.error == nil) // Main AuthFeature error should remain nil
        #expect(store.state.anonymousAuth.error == expectedError.localizedDescription)
    }

    @Test("Anonymous auth state is properly initialized")
    func anonymousAuthStateInitialization() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Verify anonymous auth state is properly initialized
        #expect(store.state.anonymousAuth.isLoading == false)
        #expect(store.state.anonymousAuth.error == nil)
    }

    @Test("Anonymous auth can be initialized with custom state")
    func anonymousAuthCustomStateInitialization() async {
        let customAnonymousState = AnonymousAuthFeature.State(
            isLoading: true,
            error: "Test error"
        )

        let customState = AuthFeature.State(
            anonymousAuth: customAnonymousState
        )

        let store = TestStore(initialState: customState) {
            AuthFeature()
        }

        // Verify custom state is preserved
        #expect(store.state.anonymousAuth.isLoading == true)
        #expect(store.state.anonymousAuth.error == "Test error")
    }

    @Test("Sign out clears user but preserves anonymous auth state")
    func signOutPreservesAnonymousAuthState() async {
        let mockUser = User(
            uid: "anonymous-uid",
            email: nil,
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: true,
            providerID: "anonymous"
        )

        let initialState = AuthFeature.State(
            user: mockUser,
            anonymousAuth: AnonymousAuthFeature.State(error: "Previous error")
        )

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        await store.send(.signOut) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.emailAuth.hasExistingAccount = false
            // Anonymous auth state should remain unchanged
        }

        // Verify anonymous auth state is preserved
        #expect(store.state.anonymousAuth.error == "Previous error")
        #expect(store.state.user == nil)
    }
}

// MARK: - Test Utilities

private enum TestError: Error, LocalizedError {
    case notImplemented
    case signInFailed

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            "Not implemented"
        case .signInFailed:
            "Sign in failed"
        }
    }
}
