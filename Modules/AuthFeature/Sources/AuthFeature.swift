import Auth0
import ComposableArchitecture
import Foundation
import JWTDecode
import DatabaseModule

@Reducer
public struct AuthFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {
        public var authenticationStatus: AuthenticationStatus = .guest
        public var currentUserId: Int?
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var authenticationResult: AuthenticationResult?

        public init() {}
    }

    public struct AuthenticationResult: Equatable, Sendable {
        public let authId: String
        public let provider: String?
        public let isAuthenticated: Bool
        public let email: String?

        public init(authId: String, provider: String?, isAuthenticated: Bool, email: String?) {
            self.authId = authId
            self.provider = provider
            self.isAuthenticated = isAuthenticated
            self.email = email
        }
    }

    public enum AuthenticationStatus: Sendable {
        case guest
        case authenticated
        case loggedIn
    }

    public enum Action: Equatable, Sendable {
        // MARK: - Authentication Actions

        case clearSession
        case signIn
        case signUp
        case signInAsGuest
        case signOut

        // MARK: - Internal Actions

        case authenticationSucceeded(authId: String, provider: String?, email: String?)
        case authenticationFailed(String)
        case setLoading(Bool)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clearSession:
                state.isLoading = true
                return .run { send in
                    do {
                        // Clear web session cookies
                        _ = try await Auth0.webAuth().clearSession()
                        print("Web session cleared")

                        #if targetEnvironment(simulator)
                            // Clear stored credentials only in simulator
                            let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
                            _ = credentialsManager.clear()
                            print("Stored credentials cleared (simulator only)")
                        #endif

                        // Reset state
                        await send(.setLoading(false))
                    } catch {
                        print("Failed to clear session: \(error)")
                        await send(.setLoading(false))
                    }
                }

            case .signIn:
                return handleSignIn(state: &state)

            case .signUp:
                return handleSignUp(state: &state)

            case .signInAsGuest:
                state.authenticationStatus = .guest
                return .none

            case .signOut:
                state.isLoading = true

                return .run { send in
                    await send(.setLoading(true))

                    do {
                        _ = try await Auth0
                            .webAuth()
                            .clearSession()

                        await MainActor.run {
                            send(.authenticationSucceeded(authId: "", provider: nil, email: ""))
                        }
                    } catch {
                        await MainActor.run {
                            send(.authenticationFailed(error.localizedDescription))
                        }
                    }
                }

            case let .authenticationSucceeded(authId, provider, email):
                state.isLoading = false
                state.authenticationStatus = authId.isEmpty ? .guest : .loggedIn

                state.errorMessage = nil
                state.authenticationResult = AuthenticationResult(
                    authId: authId,
                    provider: provider,
                    isAuthenticated: !authId.isEmpty,
                    email: email
                )

                return .none

            case let .authenticationFailed(error):
                state.isLoading = false
                state.errorMessage = error
                return .none

            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            }
        }
    }

    private func handleSignIn(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        return .run { @MainActor send in
            do {
                print("Starting Auth0 signin flow...")

                let credentials = try await Auth0
                    .webAuth()
                    .parameters([
                        "prompt": "login"
                    ])
                    .start()

                if let authId = extractUserIdFromToken(credentials.idToken) {
                    let provider = extractProviderFromToken(credentials.idToken)
                    let email = extractEmailFromToken(credentials.idToken)
                    send(.authenticationSucceeded(authId: authId, provider: provider, email: email))
                } else {
                    send(.authenticationFailed(AuthError.missingUserId.localizedDescription))
                }
            } catch {
                send(.authenticationFailed(error.localizedDescription))
            }
        }
    }

    private func handleSignUp(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        return .run { @MainActor send in
            do {
                print("Starting Auth0 signup flow...")

                let credentials = try await Auth0
                    .webAuth()
                    .parameters([
                        "screen_hint": "signup",
                        "login": "false"
                    ])
                    .start()

                print("Auth0 signup completed successfully")
                if let authId = extractUserIdFromToken(credentials.idToken) {
                    let provider = extractProviderFromToken(credentials.idToken)
                    let email = extractEmailFromToken(credentials.idToken)
                    send(.authenticationSucceeded(authId: authId, provider: provider, email: email))
                } else {
                    send(.authenticationFailed(AuthError.missingUserId.localizedDescription))
                }
            } catch {
                print("Auth0 signup failed: \(error)")
                send(.authenticationFailed(error.localizedDescription))
            }
        }
    }
}

enum AuthError: Error, LocalizedError {
    case missingUserId

    var errorDescription: String? {
        switch self {
        case .missingUserId:
            return "Authentication succeeded but user ID is missing"
        }
    }
}

private func extractUserIdFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        print("🔍 Token payload keys: \(Array(jwt.body.keys).sorted())")

        // Try multiple possible user ID fields
        if let sub = jwt.subject {
            print("✅ Found subject: \(sub)")
            return sub
        } else if let userId = jwt.body["user_id"] as? String {
            print("✅ Found user_id: \(userId)")
            return userId
        } else if let id = jwt.body["id"] as? String {
            print("✅ Found id: \(id)")
            return id
        } else {
            print("❌ No user ID field found. Available keys: \(Array(jwt.body.keys))")
            return nil
        }
    } catch {
        print("❌ Failed to decode JWT: \(error)")
        return nil
    }
}

private func extractProviderFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided for provider extraction")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        // Try extracting provider from different JWT fields
        if let provider = extractProviderFromSubject(jwt.subject) {
            return provider
        }

        if let provider = extractProviderFromIssuer(jwt.issuer) {
            return provider
        }

        if let provider = extractProviderFromIdp(jwt.body["idp"] as? String) {
            return provider
        }

        print("🔍 No specific provider found, defaulting to auth0")
        return "auth0"
    } catch {
        print("❌ Failed to decode JWT for provider extraction: \(error)")
        return nil
    }
}

private func extractProviderFromSubject(_ subject: String?) -> String? {
    guard let sub = subject else { return nil }

    print("🔍 Checking subject for provider: \(sub)")

    let providerMap = [
        "google-oauth2": "google",
        "facebook": "facebook",
        "apple": "apple",
        "twitter": "twitter",
        "github": "github",
        "linkedin": "linkedin",
        "auth0": "email"
    ]

    for (prefix, provider) in providerMap where sub.hasPrefix(prefix) {
        return provider
    }

    return nil
}

private func extractProviderFromIssuer(_ issuer: String?) -> String? {
    guard let iss = issuer else { return nil }

    print("🔍 Checking issuer for provider: \(iss)")

    let providers = ["google", "facebook", "apple"]
    for provider in providers where iss.contains(provider) {
        return provider
    }

    return nil
}

private func extractProviderFromIdp(_ idp: String?) -> String? {
    guard let idp = idp else { return nil }

    print("🔍 Found idp field: \(idp)")
    return idp.lowercased()
}

private func extractEmailFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided for email extraction")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        // Try multiple possible email fields
        if let email = jwt.body["email"] as? String, !email.isEmpty {
            print("✅ Found email: \(email)")
            return email
        }

        // Check for email in user_metadata or app_metadata
        if let userMetadata = jwt.body["user_metadata"] as? [String: Any],
           let email = userMetadata["email"] as? String, !email.isEmpty {
            print("✅ Found email in user_metadata: \(email)")
            return email
        }

        if let appMetadata = jwt.body["app_metadata"] as? [String: Any],
           let email = appMetadata["email"] as? String, !email.isEmpty {
            print("✅ Found email in app_metadata: \(email)")
            return email
        }

        // Some providers use 'name' field for email
        if let name = jwt.body["name"] as? String, name.contains("@") {
            print("✅ Found email in name field: \(name)")
            return name
        }

        // Check for email in custom fields
        if let customEmail = jwt.body["https://yourapp.com/email"] as? String, !customEmail.isEmpty {
            print("✅ Found email in custom field: \(customEmail)")
            return customEmail
        }

        // If no email found, this is normal for some providers (like Apple)
        // when users choose not to share email or Auth0 isn't configured to request it
        print("🔍 No email found in JWT token - this is normal for some providers")
        return nil
    } catch {
        print("❌ Failed to decode JWT for email extraction: \(error)")
        return nil
    }
}

// MARK: - Dependency Injection

public struct AuthStoreFactory: DependencyKey {
    public static let liveValue: @MainActor () -> StoreOf<AuthFeature> = {
        Store(initialState: AuthFeature.State()) {
            AuthFeature()
        }
    }

    public static let testValue: @MainActor () -> StoreOf<AuthFeature> = liveValue
    public static let previewValue = testValue
}

public extension DependencyValues {
    var authStoreFactory: @MainActor () -> StoreOf<AuthFeature> {
        get { self[AuthStoreFactory.self] }
        set { self[AuthStoreFactory.self] = newValue }
    }
}
