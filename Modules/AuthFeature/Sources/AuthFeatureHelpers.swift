import Auth0
import ComposableArchitecture
import Foundation
import JWTDecode

// MARK: - Auth Feature Helper Functions

// MARK: - Custom Authentication Methods

func handleCustomSignIn(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
    // For sign in, we just send OTP to existing email
    state.isOtpSent = true
    state.isAwaitingOtp = true
    // Keep showingCustomLogin true so overlay stays visible, but OTP form will show instead
    return handleSendOtp(state: &state)
}

func handleSendOtp(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
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

func handleVerifyOtp(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
    guard !state.isLoading else { return .none }
    guard !state.email.isEmpty, !state.otpCode.isEmpty else {
        state.errorMessage = "Please enter the verification code"
        return .none
    }

    state.isLoading = true
    state.errorMessage = nil

    return .run { [state = state] send in
        await send(.setLoading(true))

        do {
            print("Verifying OTP for: \(state.email)")

            // For signup flow, we'll update user metadata after successful login
            if state.showingCustomSignup && !state.username.isEmpty {
                print("Signup flow detected - will update user metadata after verification")
            }

            // Verify the OTP code
            let credentials = try await Auth0
                .authentication()
                .login(email: state.email, code: state.otpCode)
                .start()

            print("OTP verification successful")
            if let authId = extractUserIdFromToken(credentials.idToken) {
                let provider = extractProviderFromToken(credentials.idToken)
                let email = extractEmailFromToken(credentials.idToken)

                // For signup flow, log username for app-side storage
                if state.showingCustomSignup && !state.username.isEmpty {
                    print("User signup completed - username will be stored in app database: \(state.username)")
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

func handleCustomSignUp(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
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

func handleSocialSignIn(provider: String, state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
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

// MARK: - Form State Helper Functions

func showCustomLoginForm(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
    state.showingCustomLogin = true
    state.showingCustomSignup = false
    state.email = ""
    state.password = ""
    state.errorMessage = nil
    return .none
}

func showCustomSignupForm(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
    state.showingCustomLogin = false
    state.email = ""
    state.username = ""
    state.password = ""
    state.confirmPassword = ""
    state.errorMessage = nil
    return .none
}

func hideAllCustomForms(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
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
}

func prepareOtpFlow(state: inout AuthFeature.State) -> Effect<AuthFeature.Action> {
    state.isOtpSent = true
    state.isAwaitingOtp = true
    return handleSendOtp(state: &state)
}

func handleAuthenticationSuccess(
    authId: String,
    provider: String?,
    email: String?,
    state: inout AuthFeature.State
) -> Effect<AuthFeature.Action> {
    state.isLoading = false
    state.authenticationStatus = authId.isEmpty ? .guest : .loggedIn
    state.errorMessage = nil
    state.authenticationResult = AuthFeature.AuthenticationResult(
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
}
