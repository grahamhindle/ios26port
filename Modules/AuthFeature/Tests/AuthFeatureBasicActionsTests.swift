//
//  AuthFeatureBasicActionsTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import ComposableArchitecture
import Testing

@Suite("Auth Feature Basic Actions Tests")
@MainActor
struct AuthFeatureBasicActionsTests {

    @Test("Sign in as guest")
    func signInAsGuest() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.signInAsGuest) {
            $0.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        }
    }

    @Test("Authentication succeeded with empty authId makes user guest")
    func authenticationSucceededEmptyAuthId() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.authenticationSucceeded(authId: "", provider: nil, email: "")) {
            $0.isLoading = false
            $0.authenticationStatus = AuthFeature.AuthenticationStatus.guest
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "",
                provider: nil,
                isAuthenticated: false,
                email: ""
            )
            $0.showingCustomLogin = false
            $0.showingCustomSignup = false
            $0.isAwaitingOtp = false
            $0.isOtpSent = false
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.otpCode = ""
        }
    }

    @Test("Authentication succeeded with valid authId makes user logged in")
    func authenticationSucceededValidAuthId() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.authenticationSucceeded(authId: "auth123", provider: "apple", email: "user@example.com")) {
            $0.isLoading = false
            $0.authenticationStatus = AuthFeature.AuthenticationStatus.loggedIn
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "auth123",
                provider: "apple",
                isAuthenticated: true,
                email: "user@example.com"
            )
            $0.showingCustomLogin = false
            $0.showingCustomSignup = false
            $0.isAwaitingOtp = false
            $0.isOtpSent = false
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.otpCode = ""
        }
    }

    @Test("Authentication succeeded clears form state")
    func authenticationSucceededClearsFormState() async {
        var initialState = AuthFeature.State()
        initialState.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        initialState.currentUserId = nil
        initialState.isLoading = true
        initialState.errorMessage = "Some error"
        initialState.authenticationResult = nil
        initialState.email = "test@example.com"
        initialState.username = "testuser"
        initialState.password = "password"
        initialState.confirmPassword = "password"
        initialState.showingCustomLogin = true
        initialState.showingCustomSignup = false
        initialState.otpCode = "123456"
        initialState.isOtpSent = true
        initialState.isAwaitingOtp = true

        let store = TestStore(initialState: initialState) {
            AuthFeature()
        }

        await store.send(.authenticationSucceeded(authId: "auth123", provider: "google", email: "user@example.com")) {
            $0.isLoading = false
            $0.authenticationStatus = AuthFeature.AuthenticationStatus.loggedIn
            $0.errorMessage = nil
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "auth123",
                provider: "google",
                isAuthenticated: true,
                email: "user@example.com"
            )
            $0.showingCustomLogin = false
            $0.showingCustomSignup = false
            $0.isAwaitingOtp = false
            $0.isOtpSent = false
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.otpCode = ""
        }
    }

    @Test("Multiple consecutive authentication successes")
    func multipleAuthenticationSuccesses() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // First authentication
        await store.send(.authenticationSucceeded(authId: "auth1", provider: "apple", email: "user1@example.com")) {
            $0.isLoading = false
            $0.authenticationStatus = .loggedIn
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "auth1",
                provider: "apple",
                isAuthenticated: true,
                email: "user1@example.com"
            )
            $0.showingCustomLogin = false
            $0.showingCustomSignup = false
            $0.isAwaitingOtp = false
            $0.isOtpSent = false
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.otpCode = ""
        }

        // Second authentication (different user)
        await store.send(.authenticationSucceeded(authId: "auth2", provider: "google", email: "user2@example.com")) {
            $0.authenticationResult = AuthFeature.AuthenticationResult(
                authId: "auth2",
                provider: "google",
                isAuthenticated: true,
                email: "user2@example.com"
            )
        }
    }
}
