//
//  AuthFeatureFormActionsTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import ComposableArchitecture
import Testing

@Suite("Auth Feature Form Actions Tests")
@MainActor
struct AuthFeatureFormActionsTests {

    @Test("Show custom login form")
    func showCustomLoginForm() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.showCustomLogin) {
            $0.showingCustomLogin = true
            $0.showingCustomSignup = false
            $0.email = ""
            $0.password = ""
            $0.errorMessage = nil
        }
    }

    @Test("Show custom signup form")
    func showCustomSignupForm() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.showCustomSignup) {
            $0.showingCustomLogin = false
            $0.showingCustomSignup = true
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.errorMessage = nil
        }
    }

    @Test("Hide custom forms")
    func hideCustomForms() async {
        var initialState = AuthFeature.State()
        initialState.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        initialState.currentUserId = nil
        initialState.isLoading = false
        initialState.errorMessage = nil
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

        await store.send(.hideCustomForms) {
            $0.showingCustomLogin = false
            $0.showingCustomSignup = false
            $0.email = ""
            $0.username = ""
            $0.password = ""
            $0.confirmPassword = ""
            $0.otpCode = ""
            $0.isOtpSent = false
            $0.isAwaitingOtp = false
        }
    }

    @Test("Email changed")
    func emailChanged() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }
    }

    @Test("Username changed")
    func usernameChanged() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.usernameChanged("testuser")) {
            $0.username = "testuser"
        }
    }

    @Test("Password changed")
    func passwordChanged() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.passwordChanged("newpassword")) {
            $0.password = "newpassword"
        }
    }

    @Test("Confirm password changed")
    func confirmPasswordChanged() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.confirmPasswordChanged("confirmpassword")) {
            $0.confirmPassword = "confirmpassword"
        }
    }

    @Test("OTP code changed")
    func otpCodeChanged() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.otpCodeChanged("123456")) {
            $0.otpCode = "123456"
        }
    }

    @Test("Set loading state")
    func setLoadingState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.setLoading(true)) {
            $0.isLoading = true
        }

        await store.send(.setLoading(false)) {
            $0.isLoading = false
        }
    }

    @Test("Authentication failed")
    func authenticationFailed() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.authenticationFailed("Test error message")) {
            $0.isLoading = false
            $0.errorMessage = "Test error message"
        }
    }
}
