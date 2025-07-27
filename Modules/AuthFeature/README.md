# AuthFeature Module

A comprehensive authentication module built with The Composable Architecture (TCA) and Firebase Auth, providing secure user authentication flows for iOS applications.

## Features

- **Email/Password Authentication**: Sign up and sign in with email and password
- **Password Reset**: Send password reset emails to users
- **Account Management**: Delete user accounts
- **Auth State Monitoring**: Real-time authentication state changes
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Firebase Integration**: Seamless integration with Firebase Authentication
- **TCA Architecture**: Built using The Composable Architecture for predictable state management
- **Swift 6 Ready**: Full Swift 6 concurrency support with Sendable conformance

## Quick Start

### Basic Usage

```swift
import AuthFeature
import ComposableArchitecture

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            AuthView(
                store: Store(initialState: AuthFeature.State()) {
                    AuthFeature()
                }
            )
        }
    }
}
```

### Integration with Existing App

```swift
// In your parent feature's State
struct AppState {
    var auth = AuthFeature.State()
    // ... other state
}

// In your parent feature's Action
enum AppAction {
    case auth(AuthFeature.Action)
    // ... other actions
}

// In your parent feature's body
Scope(state: \.auth, action: \.auth) {
    AuthFeature()
}
```

## Architecture

### State Management

```swift
public struct State: Equatable {
    public var user: AuthUser?           // Current authenticated user
    public var isLoading = false         // Loading state for async operations
    public var error: String?           // Error messages for display
    
    public var isAuthenticated: Bool {   // Computed property for auth status
        user != nil
    }
}
```

### Available Actions

```swift
public enum Action: Sendable, Equatable {
    case onAppear                                    // Initialize auth state monitoring
    case signIn(email: String, password: String)    // Sign in with credentials
    case signUp(email: String, password: String)    // Create new account
    case signOut                                     // Sign out current user
    case resetPassword(email: String)               // Send password reset email
    case deleteAccount                              // Delete current user account
    case clearError                                 // Clear error messages
    
    // Internal response actions
    case authStateChanged(AuthUser?)
    case signInResponse(Result<AuthUser, Error>)
    case signUpResponse(Result<AuthUser, Error>)
    case signOutResponse(Result<Void, Error>)
    case resetPasswordResponse(Result<Void, Error>)
    case deleteAccountResponse(Result<Void, Error>)
}
```

### User Model

```swift
public struct AuthUser: Equatable, Codable, Sendable {
    public let uid: String              // Unique user identifier
    public let email: String?           // User's email address
    public let displayName: String?     // User's display name
    public let isEmailVerified: Bool    // Email verification status
}
```

## Authentication Flows

### Sign In Flow

```swift
// User initiates sign in
store.send(.signIn(email: "user@example.com", password: "password"))

// State updates:
// 1. isLoading = true, error = nil
// 2. signInResponse received
// 3. isLoading = false, user = AuthUser (on success) or error = message (on failure)
```

### Sign Up Flow

```swift
// User creates new account
store.send(.signUp(email: "new@example.com", password: "password123"))

// State updates:
// 1. isLoading = true, error = nil
// 2. signUpResponse received
// 3. isLoading = false, user = AuthUser (on success) or error = message (on failure)
```

### Sign Out Flow

```swift
// User signs out
store.send(.signOut)

// State updates:
// 1. isLoading = true
// 2. signOutResponse received
// 3. isLoading = false, user = nil (on success) or error = message (on failure)
```

### Password Reset Flow

```swift
// User requests password reset
store.send(.resetPassword(email: "user@example.com"))

// State updates:
// 1. isLoading = true, error = nil
// 2. resetPasswordResponse received
// 3. isLoading = false, error = nil (on success) or error = message (on failure)
```

## Firebase Setup

### 1. Firebase Project Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your project
3. Download `GoogleService-Info.plist`
4. Enable Authentication > Email/Password in Firebase Console

### 2. Project Integration

Add to your `Project.swift`:

```swift
.package(
    url: "https://github.com/firebase/firebase-ios-sdk",
    requirement: .upToNextMajor(from: "11.14.0")
)

// In target dependencies:
.package(product: "FirebaseAuth"),
.package(product: "FirebaseCore")
```

### 3. App Initialization

```swift
import FirebaseCore

@main
struct MyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // Your app content
        }
    }
}
```

### 4. Bundle Configuration

Ensure your app's bundle ID matches the one in `GoogleService-Info.plist`.

## Testing

### Running Tests

```bash
# From the AuthFeature directory
tuist generate
tuist test

# Or from the root project
tuist test AuthFeature
```

### Test Coverage

The module includes comprehensive tests covering:

- ✅ All authentication flows (sign in, sign up, sign out, password reset, delete account)
- ✅ Error handling scenarios
- ✅ Loading state management
- ✅ Auth state change monitoring
- ✅ Concurrent operation handling
- ✅ Performance testing with rapid state changes

### Example Test

```swift
@Test("Sign in success")
func signInSuccess() async {
    let mockUser = AuthUser(
        uid: "test-uid",
        email: "test@example.com",
        displayName: "Test User",
        isEmailVerified: true
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
```

## Dependencies

- **The Composable Architecture**: State management and architecture
- **Firebase Auth**: Authentication backend
- **SharedModels**: Shared data models across modules
- **SharedResources**: Shared UI resources and localization

## Development

### Independent Development

```bash
cd Modules/AuthFeature
tuist generate
```

This will generate an Xcode project with:
- **AuthFeature**: The main framework
- **AuthFeatureDemo**: A demo app for testing
- **AuthFeatureTests**: Unit tests

### Demo App

The included demo app provides a complete authentication interface for testing:

```swift
// AuthFeatureDemoApp.swift
@main
struct AuthFeatureDemoApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthView(
                store: Store(initialState: AuthFeature.State()) {
                    AuthFeature()
                }
            )
        }
    }
}
```

### Integration in Workspace

Add to your main `Workspace.swift`:

```swift
"Modules/AuthFeature"
```

## Error Handling

The module provides comprehensive error handling for common authentication scenarios:

- Invalid credentials
- Email already in use
- User not found
- Network errors
- Account requires recent authentication
- Email verification requirements

Errors are automatically converted to user-friendly messages and stored in the feature's state for display in the UI.

## Security Considerations

- Passwords are never stored in the app state
- All authentication operations use secure Firebase Auth APIs
- User sessions are managed automatically by Firebase
- Email verification status is tracked and accessible
- Account deletion requires proper authentication

## Best Practices

1. **Error Display**: Always show error messages to users when authentication fails
2. **Loading States**: Use the `isLoading` state to show progress indicators
3. **Auth State Monitoring**: Call `.onAppear` to start monitoring authentication state changes
4. **Dependency Injection**: Use the provided `AuthClient` for testing and mocking
5. **State Management**: Follow TCA patterns for predictable state updates

## API Reference

### AuthClient

The `AuthClient` provides the core authentication interface:

```swift
public struct AuthClient: Sendable {
    public var signIn: (String, String) async throws -> AuthUser
    public var signUp: (String, String) async throws -> AuthUser
    public var signOut: () async throws -> Void
    public var resetPassword: (String) async throws -> Void
    public var authStateChanges: () -> AsyncStream<AuthUser?>
    public var currentUser: AuthUser?
    public var deleteAccount: () async throws -> Void
}
```

### Live Implementation

The live implementation uses Firebase Auth:

```swift
extension AuthClient {
    public static let live: AuthClient = // Firebase implementation
}
```

### Mock Implementation

For testing, use the mock implementation:

```swift
extension AuthClient {
    static func mock(
        signInUser: AuthUser? = nil,
        shouldFailSignIn: Bool = false,
        error: Error = MockAuthError.networkError
        // ... other parameters
    ) -> AuthClient
}
```