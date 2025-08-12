import Auth0
import ComposableArchitecture
import DatabaseModule
import SwiftUI
import SharedResources

public struct AuthView: View {
    @Bindable var store: StoreOf<AuthFeature>
    @State private var isPresentingLoginSheet = false

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)

            if store.isLoading {
                ProgressView("Authenticating...")
                    .padding()
            } else {
                // Custom Login/Signup Forms
                if store.isAwaitingOtp {
                    otpVerificationForm
                } else {
                    // Main authentication options
                    mainAuthButtons
                }
            }

            // Error message
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            // Authentication result display
            if let result = store.authenticationResult, result.isAuthenticated {
                VStack(alignment: .leading, spacing: 8) {
                    Text("✅ Signed In")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text("User ID: \(result.authId)")
                    Text("Provider: \(result.provider ?? "Unknown")")
                    Text("Email: \(result.email ?? "No email")")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .sheet(isPresented: $isPresentingLoginSheet) {
            customLoginFormSheet
                .presentationDetents([.medium])
        }
    }

    private var mainAuthButtons: some View {
        VStack(spacing: 24) {
            // Custom form button
            Text("Login with Email")
                .anyButton(.callToAction) {
                    isPresentingLoginSheet = true
                }
                .buttonStyle(.borderedProminent)

            // Social login buttons
            Button(action: { store.send(.signInWithApple) }) {
                SignInWithAppleButtonView()
                    .frame(height: 50)
            }
            .accessibilityLabel("Continue with Apple")

            Button(action: { store.send(.signInWithGoogle) }) {
                SignInWithGoogleButtonView()
                    .frame(height: 50)
            }
            .accessibilityLabel("Continue with Google")
        }
    }

    private var otpVerificationForm: some View {
        VStack(spacing: 16) {
            Text("Enter Verification Code")
                .font(.title2)
                .fontWeight(.semibold)

            Text("We sent a verification code to \(store.email)")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                TextField("Verification Code", text: $store.otpCode.sending(\.otpCodeChanged))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .font(.title2)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    store.send(.hideCustomForms)
                }
                .buttonStyle(.bordered)

                Button("Verify") {
                    store.send(.verifyOtpTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.otpCode.isEmpty)
            }

            Button("Resend Code") {
                store.send(.resendOtpTapped)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var customLoginFormSheet: some View {
        VStack(spacing: 32) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            VStack(spacing: 16) {
                Text("Sign In")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Enter your email to receive a login code.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            VStack(spacing: 12) {
                TextField("Email", text: $store.email.sending(\.emailChanged))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresentingLoginSheet = false
                    store.send(.hideCustomForms)
                }
                .buttonStyle(.bordered)
                Button("Send Code") {
                    store.send(.customSignInTapped)
                    isPresentingLoginSheet = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.email.isEmpty)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .presentationDetents([.medium])
    }
}

/// A mock login buttons layout for fast visual iteration,
/// not wired to any authentication logic or store.
private struct MockLoginButtons: View {
    @State private var isPresentingLoginSheet = false
    @State private var email = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Login with Email")
                .anyButton(.callToAction) {
                    isPresentingLoginSheet = true
                }
                .buttonStyle(.borderedProminent)

            Button(action: {}) {
                // Mimic SignInWithAppleButtonView visually
                HStack {
                    Image(systemName: "applelogo")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Continue with Apple")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.black)
                .cornerRadius(8)
            }
            .frame(height: 50)
            .accessibilityLabel("Continue with Apple")

            Button(action: {}) {
                // Mimic SignInWithGoogleButtonView visually
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.black)
                    Spacer()
                    Text("Continue with Google")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(8)
            }
            .frame(height: 50)
            .accessibilityLabel("Continue with Google")
        }
        .padding()
        .sheet(isPresented: $isPresentingLoginSheet) {
            VStack(spacing: 32) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                VStack(spacing: 16) {
                    Text("Sign In")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Enter your email to receive a login code.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresentingLoginSheet = false
                    }
                    .buttonStyle(.bordered)
                    Button("Send Code") {
                        isPresentingLoginSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty)
                }
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            .presentationDetents([.medium])
        }
    }
}

#Preview("AuthView") {
    AuthView(store: Store(initialState: AuthFeature.State()) {
        AuthFeature()
    })
}

#Preview("AuthView - Login Layout Mock") {
    MockLoginButtons()
}

/// Preview: Default (Initial) State - main login layout
#Preview("AuthView - Default (Initial) State") {
    AuthView(store: Store(initialState: AuthFeature.State()) {
        AuthFeature()
    })
}

/// Preview: Loading state with isLoading = true
#Preview("AuthView - Loading") {
    AuthView(store: Store(initialState: {
        var state = AuthFeature.State()
        state.isLoading = true
        return state
    }()) {
        AuthFeature()
    })
}

/// Preview: OTP Entry state with isAwaitingOtp = true, email prefilled, otpCode empty
#Preview("AuthView - OTP Entry") {
    AuthView(store: Store(initialState: {
        var state = AuthFeature.State()
        state.isAwaitingOtp = true
        state.email = "user@example.com"
        state.otpCode = ""
        return state
    }()) {
        AuthFeature()
    })
}

/// Preview: Error message shown, with errorMessage set, not loading or awaiting OTP
///
///
#Preview("AuthView - Error Shown") {

    AuthView(store: Store(initialState: {
        var state = AuthFeature.State()
        state.errorMessage = "Invalid login credentials. Please try again."
        return state
    }()) {
        AuthFeature()
    })
}

/// Preview: Signed In state with authenticationResult populated and isAuthenticated true
#Preview("AuthView - Signed In") {

    AuthView(store: Store(initialState: {
        var state = AuthFeature.State()
        state.authenticationResult = AuthFeature.AuthenticationResult(
            authId: "auth0|1234567890",
            provider: "Auth0",
            isAuthenticated: true,
            email: "user@example.com"
        )
        return state

    }()) {
        AuthFeature()
    })

}
