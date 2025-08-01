import Auth0
import ComposableArchitecture
import Foundation
import SharedModels



@Reducer
public struct AuthFeature {

    public init() {}
@ObservableState
    public struct State: Equatable {
        public var authenticationStatus: AuthenticationStatus = .guest
        public var currentUserId: Int? = nil
        public var isLoading: Bool = false
        public var errorMessage: String? = nil
        public var authenticationResult: AuthenticationResult? = nil

        public init() {}
    }

    public struct AuthenticationResult: Equatable {

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

    public enum AuthenticationStatus {
        case guest
        case authenticated
        case loggedIn
    }

    public enum Action {
        // MARK: - Authentication Actions
        case clearSession
        case signIn
        case signUp
        case signInAsGuest
        case signOut

        // MARK: - Internal Actions
        case authenticationSucceeded(authId: String, provider: String?, email: String?)
        case authenticationFailed(Error)
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
                        guard !state.isLoading else { return .none }
                        state.isLoading = true

                        return .run { @MainActor send in
                            do {
                                print("Starting Auth0 signin flow...")
                                
                                let credentials = try await Auth0
                                    .webAuth()
                                    .parameters(["screen_hint": "login"])
                                    .start()

                                if let authId = extractUserIdFromToken(credentials.idToken) {
                                    let provider = extractProviderFromToken(credentials.idToken)
                                    let email = extractEmailFromToken(credentials.idToken)
                                    send(.authenticationSucceeded(authId: authId, provider: provider, email: email))

                                } else {
                                    send(.authenticationFailed(AuthError.missingUserId))
                                }
                            } catch {
                                send(.authenticationFailed(error))
                            }
                        }
            case  .signUp:
                    guard !state.isLoading else { return .none }
                    state.isLoading = true

                    return .run { @MainActor send in
                        do {
                            print("Starting Auth0 signup flow...")
                            
                            let credentials = try await Auth0
                                .webAuth()
                                .parameters(["screen_hint": "signup"])
                                .start()
                    
                            print("Auth0 signup completed successfully")
                            if let authId = extractUserIdFromToken(credentials.idToken) {
                                let provider = extractProviderFromToken(credentials.idToken)
                                let email = extractEmailFromToken(credentials.idToken)
                                send(.authenticationSucceeded(authId: authId, provider: provider, email: email))
                            } else {
                                send(.authenticationFailed(AuthError.missingUserId))
                            }
                        } catch {
                            print("Auth0 signup failed: \(error)")
                            send(.authenticationFailed(error))
                        }
                    }

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
                                send(.authenticationFailed(error))
                            }
                        }
                    }

            case let .authenticationSucceeded( authId, provider, email):
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
                state.errorMessage = error.localizedDescription
                return .none

            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
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
    guard let token = idToken else { return nil }

    let segments = token.components(separatedBy: ".")
    guard segments.count == 3 else { return nil }

    let payload = segments[1]
    var base64String = payload

    // Add padding if needed for base64 decoding
    let remainder = base64String.count % 4
    if remainder > 0 {
        base64String += String(repeating: "=", count: 4 - remainder)
    }

    guard let data = Data(base64Encoded: base64String),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let sub = json["sub"] as? String else {
        return nil
    }

    return sub
}

private func extractProviderFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else { return nil }

    let segments = token.components(separatedBy: ".")
    guard segments.count == 3 else { return nil }

    let payload = segments[1]
    var base64String = payload

    // Add padding if needed for base64 decoding
    let remainder = base64String.count % 4
    if remainder > 0 {
        base64String += String(repeating: "=", count: 4 - remainder)
    }

    guard let data = Data(base64Encoded: base64String),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }

    // Check for social provider in sub field (e.g., "google-oauth2|123", "auth0|123")
    if let sub = json["sub"] as? String {
        if sub.hasPrefix("google-oauth2") {
            return "google"
        } else if sub.hasPrefix("facebook") {
            return "facebook"
        } else if sub.hasPrefix("apple") {
            return "apple"
        } else if sub.hasPrefix("twitter") {
            return "twitter"
        } else if sub.hasPrefix("github") {
            return "github"
        } else if sub.hasPrefix("linkedin") {
            return "linkedin"
        } else if sub.hasPrefix("auth0") {
            return "email"
        }
    }
    
    // Also check the 'iss' (issuer) field for additional provider info
    if let iss = json["iss"] as? String {
        if iss.contains("google") {
            return "google"
        } else if iss.contains("facebook") {
            return "facebook"
        } else if iss.contains("apple") {
            return "apple"
        }
    }
    
    // Check 'idp' field which some providers use
    if let idp = json["idp"] as? String {
        return idp.lowercased()
    }

    return "auth0"
}

private func extractEmailFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else { return nil }

    let segments = token.components(separatedBy: ".")
    guard segments.count == 3 else { return nil }

    let payload = segments[1]
    var base64String = payload

    // Add padding if needed for base64 decoding
    let remainder = base64String.count % 4
    if remainder > 0 {
        base64String += String(repeating: "=", count: 4 - remainder)
    }

    guard let data = Data(base64Encoded: base64String),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }
    
    // Try multiple possible email fields
    if let email = json["email"] as? String, !email.isEmpty {
        return email
    }
    
    // Some providers use email_verified along with email
    if let email = json["email"] as? String, !email.isEmpty {
        return email
    }
    
    // Check for email in user_metadata or app_metadata
    if let userMetadata = json["user_metadata"] as? [String: Any],
       let email = userMetadata["email"] as? String, !email.isEmpty {
        return email
    }
    
    if let appMetadata = json["app_metadata"] as? [String: Any],
       let email = appMetadata["email"] as? String, !email.isEmpty {
        return email
    }
    
    // Some providers use 'name' field for email
    if let name = json["name"] as? String, name.contains("@") {
        return name
    }
    
    // Check for email in custom fields
    if let customEmail = json["https://yourapp.com/email"] as? String, !customEmail.isEmpty {
        return customEmail
    }
    
    // If no email found, this is normal for some providers (like Apple)
    // when users choose not to share email or Auth0 isn't configured to request it
    print("No email found in JWT token - this is normal for some providers")
    
    return nil
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

extension DependencyValues {
    public var authStoreFactory: @MainActor () -> StoreOf<AuthFeature> {
        get { self[AuthStoreFactory.self] }
        set { self[AuthStoreFactory.self] = newValue }
    }
}
