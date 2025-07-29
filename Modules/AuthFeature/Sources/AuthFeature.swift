import Auth0
import ComposableArchitecture
import Foundation
import SharedModels


@Reducer
public struct AuthFeature {

    public init() {}

    @ObservableState
    public struct State {
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
        
        public init(authId: String, provider: String?, isAuthenticated: Bool) {

            self.authId = authId
            self.provider = provider
            self.isAuthenticated = isAuthenticated
        }
    }
    
    public enum AuthenticationStatus {
        case guest
        case authenticated
        case loggedIn
    }

    public enum Action {
        // MARK: - Authentication Actions
        case signIn
        case signUp
        case signInAsGuest
        case signOut
        
        // MARK: - Internal Actions
        case authenticationSucceeded(authId: String, provider: String?)
        case authenticationFailed(Error)
        case setLoading(Bool)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                    case .signIn:
                        state.isLoading = true

                        return .run { send in
                            await send(.setLoading(true))

                            do {
                                let credentials = try await Auth0
                                    .webAuth()
                                    .parameters(["screen_hint": "login"])
                                    .start()

                                await MainActor.run {
                                    if let authId = extractUserIdFromToken(credentials.idToken) {
                                        let provider = extractProviderFromToken(credentials.idToken)
                                        send(.authenticationSucceeded(authId: authId, provider: provider))
                                    } else {
                                        send(.authenticationFailed(AuthError.missingUserId))
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    send(.authenticationFailed(error))
                                }
                            }
                        }
            case  .signUp:
                
                    state.isLoading = true

                    return .run { send in
                        await send(.setLoading(true))

                        do {
                            let credentials = try await Auth0
                                .webAuth()
                                .parameters(["screen_hint": "signup"])
                                .start()

                            await MainActor.run {
                                if let authId = extractUserIdFromToken(credentials.idToken) {
                                    let provider = extractProviderFromToken(credentials.idToken)
                                    send(.authenticationSucceeded(authId: authId, provider: provider))
                                } else {
                                    send(.authenticationFailed(AuthError.missingUserId))
                                }
                            }
                        } catch {
                            await MainActor.run {
                                send(.authenticationFailed(error))
                            }
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
                                send(.authenticationSucceeded(authId: "", provider: nil))
                            }
                        } catch {
                            await MainActor.run {
                                send(.authenticationFailed(error))
                            }
                        }
                    }

            case let .authenticationSucceeded( authId, provider):
                state.isLoading = false
                state.authenticationStatus = authId.isEmpty ? .guest : .loggedIn

                state.errorMessage = nil
                state.authenticationResult = AuthenticationResult(
                    authId: authId,
                    provider: provider,
                    isAuthenticated: !authId.isEmpty
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
        } else if sub.hasPrefix("auth0") {
            return "email"
        }
    }
    
    return "auth0"
}


