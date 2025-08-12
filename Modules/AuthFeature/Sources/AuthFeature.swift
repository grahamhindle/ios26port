import Auth0
import ComposableArchitecture
import DatabaseModule
import Foundation
import JWTDecode

@Reducer
public struct AuthFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {
        public var authenticationStatus: AuthenticationStatus = .guest
        public var currentUserId: Int?
        public var isLoading = false
        public var errorMessage: String?
        public var authenticationResult: AuthenticationResult?
        
        // Custom form fields
        public var email = ""
        public var username = ""
        public var password = ""
        public var confirmPassword = ""
        public var showingCustomLogin = false
        public var showingCustomSignup = false
        
        // OTP fields
        public var otpCode = ""
        public var isOtpSent = false
        public var isAwaitingOtp = false

        public init() {}
        
        public var authSheet: AuthSheet? {
            if showingCustomLogin {
                return .login
            } else if showingCustomSignup {
                return .signup
            } else if isAwaitingOtp {
                return .otp
            }
            return nil
        }
    }
    
    public enum AuthSheet: String, Identifiable {
        case login
        case signup  
        case otp
        
        public var id: String { rawValue }
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
        
        // MARK: - Custom Form Actions
        case showCustomLogin
        case showCustomSignup
        case hideCustomForms
        case emailChanged(String)
        case usernameChanged(String)
        case passwordChanged(String)
        case confirmPasswordChanged(String)
        case customSignInTapped
        case customSignUpTapped
        
        // OTP Actions
        case otpCodeChanged(String)
        case sendOtpTapped
        case verifyOtpTapped
        case resendOtpTapped
        
        // MARK: - Social Login Actions
        case signInWithApple
        case signInWithGoogle

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
                
            // MARK: - Custom Form Actions
            case .showCustomLogin:
                state.showingCustomLogin = true
                state.showingCustomSignup = false
                state.email = ""
                state.password = ""
                state.errorMessage = nil
                return .none
                
            case .showCustomSignup:
                state.showingCustomSignup = true
                state.showingCustomLogin = false
                state.email = ""
                state.username = ""
                state.password = ""
                state.confirmPassword = ""
                state.errorMessage = nil
                return .none
                
            case .hideCustomForms:
                state.showingCustomLogin = false
                state.showingCustomSignup = false
                state.email = ""
                state.username = ""
                state.password = ""
                state.confirmPassword = ""
                state.otpCode = ""
                state.isOtpSent = false
                state.isAwaitingOtp = false
                return .none
                
            case let .emailChanged(email):
                state.email = email
                return .none
                
            case let .usernameChanged(username):
                state.username = username
                return .none
                
            case let .passwordChanged(password):
                state.password = password
                return .none
                
            case let .confirmPasswordChanged(confirmPassword):
                state.confirmPassword = confirmPassword
                return .none
                
            // OTP Actions
            case let .otpCodeChanged(code):
                state.otpCode = code
                return .none
                
            case .sendOtpTapped:
                state.isOtpSent = true
                state.isAwaitingOtp = true
                return handleSendOtp(state: &state)
                
            case .verifyOtpTapped:
                return handleVerifyOtp(state: &state)
                
            case .resendOtpTapped:
                return handleSendOtp(state: &state)
                
            case .customSignInTapped:
                return handleCustomSignIn(state: &state)
                
            case .customSignUpTapped:
                return handleCustomSignUp(state: &state)
                
            case .signInWithApple:
                return handleSocialSignIn(provider: "apple", state: &state)
                
            case .signInWithGoogle:
                return handleSocialSignIn(provider: "google-oauth2", state: &state)

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
                
                // Reset form states when authentication succeeds
                state.showingCustomLogin = false
                state.showingCustomSignup = false
                state.isAwaitingOtp = false
                state.isOtpSent = false
                state.email = ""
                state.username = ""
                state.password = ""
                state.confirmPassword = ""
                state.otpCode = ""

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
                        "prompt": "login",
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
                        "login": "false",
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

    // MARK: - Custom Authentication Methods
    
    private func handleCustomSignIn(state: inout State) -> Effect<Action> {
        // For sign in, we just send OTP to existing email
        state.isOtpSent = true
        state.isAwaitingOtp = true
        // Keep showingCustomLogin true so overlay stays visible, but OTP form will show instead
        return handleSendOtp(state: &state)
    }
    
    private func handleSendOtp(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        guard !state.email.isEmpty else {
            state.errorMessage = "Please enter your email address"
            return .none
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { [email = state.email] send in
            await send(.setLoading(true))
            
            do {
                print("Starting Auth0 passwordless flow for: \(email)")
                _ = try await Auth0
                    .authentication()
                    .startPasswordless(email: email, connection: "email")
                    .start()
                
                print("OTP sent successfully to: \(email)")
                #if DEBUG
                // In development, you could add test OTP codes here
                print("🔐 TEST MODE: For testing, try OTP: 123456")
                #endif
                await MainActor.run {
                    send(.setLoading(false))
                }
            } catch {
                print("Failed to send OTP: \(error)")
                await MainActor.run {
                    send(.authenticationFailed("Failed to send verification code. Please try again."))
                }
            }
        }
    }
    
    private func handleVerifyOtp(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        guard !state.email.isEmpty, !state.otpCode.isEmpty else {
            state.errorMessage = "Please enter the verification code"
            return .none
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { [email = state.email, otpCode = state.otpCode, username = state.username, showingSignup = state.showingCustomSignup] send in
            await send(.setLoading(true))
            
            do {
                print("Verifying OTP for: \(email)")
                
                // For signup flow, we'll update user metadata after successful login
                if showingSignup && !username.isEmpty {
                    print("Signup flow detected - will update user metadata after verification")
                }
                
                // Verify the OTP code
                let credentials = try await Auth0
                    .authentication()
                    .login(email: email, code: otpCode)
                    .start()
                
                print("OTP verification successful")
                if let authId = extractUserIdFromToken(credentials.idToken) {
                    let provider = extractProviderFromToken(credentials.idToken)
                    let email = extractEmailFromToken(credentials.idToken)
                    
                    // For signup flow, log username for app-side storage
                    if showingSignup && !username.isEmpty {
                        print("User signup completed - username will be stored in app database: \(username)")
                    }
                    
                    await MainActor.run {
                        send(.authenticationSucceeded(authId: authId, provider: provider, email: email))
                    }
                } else {
                    await MainActor.run {
                        send(.authenticationFailed(AuthError.missingUserId.localizedDescription))
                    }
                }
            } catch {
                print("OTP verification failed: \(error)")
                await MainActor.run {
                    send(.authenticationFailed("Invalid verification code. Please try again."))
                }
            }
        }
    }
    
    private func handleCustomSignUp(state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        guard !state.email.isEmpty, !state.username.isEmpty else {
            state.errorMessage = "Please enter email and username"
            return .none
        }
        guard state.username.count >= 3 else {
            state.errorMessage = "Username must be at least 3 characters"
            return .none
        }
        
        // For signup with OTP, we first send OTP and store username for later
        state.isOtpSent = true
        state.isAwaitingOtp = true
        return handleSendOtp(state: &state)
    }
    
    private func handleSocialSignIn(provider: String, state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { send in
            await send(.setLoading(true))
            
            do {
                print("Starting Auth0 social signin with provider: \(provider)")
                let credentials = try await Auth0
                    .webAuth()
                    .connection(provider)
                    .start()
                
                print("Auth0 social signin completed successfully")
                if let authId = extractUserIdFromToken(credentials.idToken) {
                    let provider = extractProviderFromToken(credentials.idToken)
                    let email = extractEmailFromToken(credentials.idToken)
                    await MainActor.run {
                        send(.authenticationSucceeded(authId: authId, provider: provider, email: email))
                    }
                } else {
                    await MainActor.run {
                        send(.authenticationFailed(AuthError.missingUserId.localizedDescription))
                    }
                }
            } catch {
                print("Auth0 social signin failed: \(error)")
                await MainActor.run {
                    send(.authenticationFailed(error.localizedDescription))
                }
            }
        }
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
