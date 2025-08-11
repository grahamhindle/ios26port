@testable import AuthFeature
import AuthService
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@Suite("Auth Feature Sign In Tests", .serialized)
@MainActor
struct AuthSignInTests {
    @Test("Feature initializes with correct state")
    func initialState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        #expect(store.state.isLoading == false)
        #expect(store.state.user == nil)
        #expect(store.state.error == nil)
        #expect(store.state.isAuthenticated == false)
    }

    @Test("Sign in success")
    func signInSuccess() async {
        let mockUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signInUser: mockUser)
        }

        await store.send(.signIn(email: "test@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInResponse(.success(mockUser))) {
            $0.isLoading = false
            $0.user = mockUser
        }

        #expect(store.state.isAuthenticated == true)
    }

    @Test("Sign in failure")
    func signInFailure() async {
        let mockError = MockAuthError.invalidCredentials

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailSignIn: true, error: mockError)
        }

        await store.send(.signIn(email: "test@example.com", password: "wrong")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }

        #expect(store.state.isAuthenticated == false)
    }
}

@Suite("Auth Feature Sign Up Tests", .serialized)
@MainActor
struct AuthSignUpTests {
    @Test("Sign up success")
    func signUpSuccess() async {
        let mockUser = User(
            uid: "new-uid",
            email: "new@example.com",
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signUpUser: mockUser)
        }

        await store.send(.signUp(email: "new@example.com", password: "password123")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signUpResponse(.success(mockUser))) {
            $0.isLoading = false
            $0.user = mockUser
        }

        #expect(store.state.isAuthenticated == true)
    }

    @Test("Sign up failure")
    func signUpFailure() async {
        let mockError = MockAuthError.emailAlreadyInUse

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailSignUp: true, error: mockError)
        }

        await store.send(.signUp(email: "existing@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signUpResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }
    }
}

@Suite("Auth Feature Anonymous Tests", .serialized)
@MainActor
struct AuthAnonymousTests {
    @Test("Sign in anonymously success")
    func signInAnonymouslySuccess() async {
        let mockAnonymousUser = User(
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
            $0.authClient = .mock(signInAnonymouslyUser: mockAnonymousUser)
        }

        await store.send(.signInAnonymously) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInAnonymouslyResponse(.success(mockAnonymousUser))) {
            $0.isLoading = false
            $0.user = mockAnonymousUser
        }

        #expect(store.state.isAuthenticated == true)
        #expect(store.state.user?.isAnonymous == true)
    }

    @Test("Sign in anonymously failure")
    func signInAnonymouslyFailure() async {
        let mockError = MockAuthError.networkError

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailSignInAnonymously: true, error: mockError)
        }

        await store.send(.signInAnonymously) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInAnonymouslyResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }

        #expect(store.state.isAuthenticated == false)
    }

    @Test("Anonymous user can upgrade to full account")
    func anonymousUserUpgrade() async {
        let anonymousUser = User(
            uid: "anonymous-uid",
            email: nil,
            displayName: nil,
            isEmailVerified: false,
            isAnonymous: true,
            providerID: "anonymous"
        )

        let upgradedUser = User(
            uid: "anonymous-uid",
            email: "upgraded@example.com",
            displayName: "Upgraded User",
            isEmailVerified: false,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(
            initialState: AuthFeature.State(user: anonymousUser)
        ) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signUpUser: upgradedUser)
        }

        await store.send(.signUp(email: "upgraded@example.com", password: "password123")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signUpResponse(.success(upgradedUser))) {
            $0.isLoading = false
            $0.user = upgradedUser
        }

        #expect(store.state.user?.isAnonymous == false)
        #expect(store.state.user?.email == "upgraded@example.com")
    }
}

@Suite("Auth Feature Apple Sign In Tests", .serialized)
@MainActor
struct AuthAppleSignInTests {
    @Test("Sign in with Apple success")
    func signInWithAppleSuccess() async {
        let mockAppleUser = User(
            uid: "apple-uid",
            email: "user@privaterelay.appleid.com",
            displayName: "Apple User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "apple.com"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signInWithAppleUser: mockAppleUser)
        }

        await store.send(.signInWithApple) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInWithAppleResponse(.success(mockAppleUser))) {
            $0.isLoading = false
            $0.user = mockAppleUser
        }

        #expect(store.state.isAuthenticated == true)
        #expect(store.state.user?.providerID == "apple.com")
    }

    @Test("Sign in with Apple failure")
    func signInWithAppleFailure() async {
        let mockError = MockAuthError.appleSignInCancelled

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailSignInWithApple: true, error: mockError)
        }

        await store.send(.signInWithApple) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInWithAppleResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }

        #expect(store.state.isAuthenticated == false)
    }
}

@Suite("Auth Feature Sign Out Tests", .serialized)
@MainActor
struct AuthSignOutTests {
    @Test("Sign out success")
    func signOutSuccess() async {
        let initialUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(
            initialState: AuthFeature.State(user: initialUser)
        ) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock()
        }

        await store.send(.signOut) {
            $0.isLoading = true
        }

        await store.receive(.signOutResponse(.success(()))) {
            $0.isLoading = false
            $0.user = nil
        }

        #expect(store.state.isAuthenticated == false)
    }
}

@Suite("Auth Feature Reset Password Tests", .serialized)
@MainActor
struct AuthResetPasswordTests {
    @Test("Reset password success")
    func resetPasswordSuccess() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock()
        }

        await store.send(.resetPassword(email: "test@example.com")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.resetPasswordResponse(.success(()))) {
            $0.isLoading = false
        }
    }

    @Test("Reset password failure")
    func resetPasswordFailure() async {
        let mockError = MockAuthError.userNotFound

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailResetPassword: true, error: mockError)
        }

        await store.send(.resetPassword(email: "nonexistent@example.com")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.resetPasswordResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }
    }
}

@Suite("Auth Feature Delete Account Tests", .serialized)
@MainActor
struct AuthDeleteAccountTests {
    @Test("Delete account success")
    func deleteAccountSuccess() async {
        let initialUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(
            initialState: AuthFeature.State(user: initialUser)
        ) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock()
        }

        await store.send(.deleteAccount) {
            $0.isLoading = true
        }

        await store.receive(.deleteAccountResponse(.success(()))) {
            $0.isLoading = false
            $0.user = nil
        }

        #expect(store.state.isAuthenticated == false)
    }

    @Test("Delete account failure")
    func deleteAccountFailure() async {
        let initialUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )
        let mockError = MockAuthError.requiresRecentLogin

        let store = TestStore(
            initialState: AuthFeature.State(user: initialUser)
        ) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(shouldFailDeleteAccount: true, error: mockError)
        }

        await store.send(.deleteAccount) {
            $0.isLoading = true
        }

        await store.receive(.deleteAccountResponse(.failure(mockError))) {
            $0.isLoading = false
            $0.error = mockError.localizedDescription
        }

        #expect(store.state.user != nil)
    }
}

@Suite("Auth Feature Auth State Changes Tests", .serialized)
@MainActor
struct AuthAuthStateChangesTests {
    @Test("Auth state changes")
    func authStateChanges() async {
        let mockUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(authStateUser: mockUser)
        }

        await store.send(.onAppear)
        await store.receive(.authStateChanged(mockUser)) {
            $0.user = mockUser
        }

        #expect(store.state.isAuthenticated == true)
    }
}

@Suite("Auth Feature Clear Error Tests", .serialized)
@MainActor
struct AuthClearErrorTests {
    @Test("Clear error")
    func clearError() async {
        let store = TestStore(
            initialState: AuthFeature.State(error: "Some error")
        ) {
            AuthFeature()
        }

        await store.send(.clearError) {
            $0.error = nil
        }
    }
}

@Suite("Auth Feature Multiple Concurrent Sign In Requests Tests", .serialized)
@MainActor
struct AuthConcurrentSignInTests {
    @Test("Multiple concurrent sign in requests")
    func multipleConcurrentSignInRequests() async {
        let mockUser = User(
            uid: "test-uid",
            email: "test@example.com",
            displayName: "Test User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signInUser: mockUser)
        }

        await store.send(.signIn(email: "test@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInResponse(.success(mockUser))) {
            $0.isLoading = false
            $0.user = mockUser
        }

        await store.send(.signIn(email: "test@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInResponse(.success(mockUser))) {
            $0.isLoading = false
            $0.user = mockUser
        }
    }
}

// MARK: - Test Utilities

enum AuthTestUtilities {
    static func createMockUser(
        uid: String = "test-uid",
        email: String = "test@example.com",
        displayName: String? = "Test User",
        isEmailVerified: Bool = true,
        isAnonymous: Bool = false,
        providerID: String? = "password"
    ) -> User {
        User(
            uid: uid,
            email: email,
            displayName: displayName,
            isEmailVerified: isEmailVerified,
            isAnonymous: isAnonymous,
            providerID: providerID
        )
    }
}

// MARK: - Mock Auth Error

enum MockAuthError: Error, LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case userNotFound
    case requiresRecentLogin
    case networkError
    case appleSignInCancelled
    case appleSignInFailed
    case anonymousSignInDisabled

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Invalid email or password"
        case .emailAlreadyInUse:
            "Email is already in use"
        case .userNotFound:
            "User not found"
        case .requiresRecentLogin:
            "This operation requires recent authentication"
        case .networkError:
            "Network error occurred"
        case .appleSignInCancelled:
            "Apple Sign In was cancelled"
        case .appleSignInFailed:
            "Apple Sign In failed"
        case .anonymousSignInDisabled:
            "Anonymous sign in is disabled"
        }
    }
}

// MARK: - Mock AuthClient

extension AuthClient {
    static func mock(
        signInUser: User? = nil,
        signUpUser: User? = nil,
        signInAnonymouslyUser: User? = nil,
        signInWithAppleUser: User? = nil,
        authStateUser: User? = nil,
        shouldFailSignIn: Bool = false,
        shouldFailSignUp: Bool = false,
        shouldFailSignInAnonymously: Bool = false,
        shouldFailSignInWithApple: Bool = false,
        shouldFailSignOut: Bool = false,
        shouldFailResetPassword: Bool = false,
        shouldFailDeleteAccount: Bool = false,
        error: Error = MockAuthError.networkError,
        delay: TimeInterval = 0
    ) -> AuthClient {
        AuthClient(
            signIn: { email, _ in
                if delay > 0 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
                if shouldFailSignIn {
                    throw error
                }
                return signInUser ?? User(
                    uid: "mock-uid",
                    email: email,
                    displayName: nil,
                    isEmailVerified: false,
                    isAnonymous: false,
                    providerID: "password"
                )
            },
            signUp: { email, _ in
                if shouldFailSignUp {
                    throw error
                }
                return signUpUser ?? User(
                    uid: "mock-new-uid",
                    email: email,
                    displayName: nil,
                    isEmailVerified: false,
                    isAnonymous: false,
                    providerID: "password"
                )
            },
            signInAnonymously: {
                if shouldFailSignInAnonymously {
                    throw error
                }
                return signInAnonymouslyUser ?? User(
                    uid: "mock-anonymous-uid",
                    email: nil,
                    displayName: nil,
                    isEmailVerified: false,
                    isAnonymous: true,
                    providerID: "anonymous"
                )
            },
            signInWithApple: {
                if shouldFailSignInWithApple {
                    throw error
                }
                return signInWithAppleUser ?? User(
                    uid: "mock-apple-uid",
                    email: "user@privaterelay.appleid.com",
                    displayName: "Apple User",
                    isEmailVerified: true,
                    isAnonymous: false,
                    providerID: "apple.com"
                )
            },
            signOut: {
                if shouldFailSignOut {
                    throw error
                }
            },
            resetPassword: { _ in
                if shouldFailResetPassword {
                    throw error
                }
            },
            authStateChanges: {
                AsyncStream { continuation in
                    if let user = authStateUser {
                        continuation.yield(user)
                    } else {
                        continuation.yield(nil)
                    }
                    continuation.finish()
                }
            },
            currentUser: authStateUser,
            deleteAccount: {
                if shouldFailDeleteAccount {
                    throw error
                }
            }
        )
    }
}

// MARK: - Performance Tests

@Suite("Auth Performance Tests")
@MainActor
struct AuthPerformanceTests {
    @Test("Rapid authentication state changes")
    func rapidAuthStateChanges() async {
        let users = (1 ... 100).map { index in
            User(
                uid: "user-\(index)",
                email: "user\(index)@example.com",
                displayName: "User \(index)",
                isEmailVerified: true,
                isAnonymous: false,
                providerID: "password"
            )
        }

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = AuthClient(
                signIn: { _, _ in users[0] },
                signUp: { _, _ in users[0] },
                signInAnonymously: { users[0] },
                signInWithApple: { users[0] },
                signOut: {},
                resetPassword: { _ in },
                authStateChanges: {
                    AsyncStream { continuation in
                        for user in users {
                            continuation.yield(user)
                        }
                        continuation.finish()
                    }
                },
                currentUser: nil,
                deleteAccount: {}
            )
        }

        await store.send(.onAppear)

        for user in users {
            await store.receive(.authStateChanged(user)) {
                $0.user = user
            }
        }

        #expect(store.state.user?.uid == "user-100")
    }

    @Test("Sequential authentication operations")
    func sequentialAuthOperations() async {
        let signInUser = User(
            uid: "signin-uid",
            email: "test@example.com",
            displayName: "Sign In User",
            isEmailVerified: true,
            isAnonymous: false,
            providerID: "password"
        )

        let signUpUser = User(
            uid: "signup-uid",
            email: "new@example.com",
            displayName: "Sign Up User",
            isEmailVerified: false,
            isAnonymous: false,
            providerID: "password"
        )

        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock(signInUser: signInUser, signUpUser: signUpUser)
        }

        await store.send(.signIn(email: "test@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signInResponse(.success(signInUser))) {
            $0.isLoading = false
            $0.user = signInUser
        }

        await store.send(.signUp(email: "new@example.com", password: "password")) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(.signUpResponse(.success(signUpUser))) {
            $0.isLoading = false
            $0.user = signUpUser
        }
    }
}
