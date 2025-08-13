//
//  AuthFeatureHelperFunctionsTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import ComposableArchitecture
import Testing

@Suite("Auth Feature Helper Functions Tests")
@MainActor
struct AuthFeatureHelperFunctionsTests {

    @Test("showCustomLoginForm helper function")
    func showCustomLoginFormHelper() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        state.currentUserId = nil
        state.isLoading = false
        state.errorMessage = "Previous error"
        state.authenticationResult = nil
        state.email = "old@example.com"
        state.username = "olduser"
        state.password = "oldpassword"
        state.confirmPassword = "oldconfirm"
        state.showingCustomLogin = false
        state.showingCustomSignup = true
        state.otpCode = ""
        state.isOtpSent = false
        state.isAwaitingOtp = false

        let effect = showCustomLoginForm(state: &state)

        #expect(state.showingCustomLogin == true)
        #expect(state.showingCustomSignup == false)
        #expect(state.email == "")
        #expect(state.password == "")
        #expect(state.errorMessage == nil)

        // Other fields should remain unchanged
        #expect(state.username == "olduser")
        #expect(state.confirmPassword == "oldconfirm")

        // Effect should be none - we'll just verify it doesn't crash
    }

    @Test("showCustomSignupForm helper function")
    func showCustomSignupFormHelper() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        state.currentUserId = nil
        state.isLoading = false
        state.errorMessage = "Previous error"
        state.authenticationResult = nil
        state.email = "old@example.com"
        state.username = "olduser"
        state.password = "oldpassword"
        state.confirmPassword = "oldconfirm"
        state.showingCustomLogin = true
        state.showingCustomSignup = false
        state.otpCode = ""
        state.isOtpSent = false
        state.isAwaitingOtp = false

        let effect = showCustomSignupForm(state: &state)

        #expect(state.showingCustomLogin == false)
        #expect(state.showingCustomSignup == true)
        #expect(state.email == "")
        #expect(state.username == "")
        #expect(state.password == "")
        #expect(state.confirmPassword == "")
        #expect(state.errorMessage == nil)

        // Effect should be none - we'll just verify it doesn't crash
    }

    @Test("hideAllCustomForms helper function")
    func hideAllCustomFormsHelper() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        state.currentUserId = nil
        state.isLoading = false
        state.errorMessage = nil
        state.authenticationResult = nil
        state.email = "test@example.com"
        state.username = "testuser"
        state.password = "password"
        state.confirmPassword = "confirmpass"
        state.showingCustomLogin = true
        state.showingCustomSignup = true
        state.otpCode = "123456"
        state.isOtpSent = true
        state.isAwaitingOtp = true

        let effect = hideAllCustomForms(state: &state)

        #expect(state.showingCustomLogin == false)
        #expect(state.showingCustomSignup == false)
        #expect(state.email == "")
        #expect(state.username == "")
        #expect(state.password == "")
        #expect(state.confirmPassword == "")
        #expect(state.otpCode == "")
        #expect(state.isOtpSent == false)
        #expect(state.isAwaitingOtp == false)

        // Effect should be none - we'll just verify it doesn't crash
    }

    @Test("handleAuthenticationSuccess helper function with valid authId")
    func handleAuthenticationSuccessValidAuthId() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        state.currentUserId = nil
        state.isLoading = true
        state.errorMessage = "Some error"
        state.authenticationResult = nil
        state.email = "test@example.com"
        state.username = "testuser"
        state.password = "password"
        state.confirmPassword = "confirmpass"
        state.showingCustomLogin = true
        state.showingCustomSignup = false
        state.otpCode = "123456"
        state.isOtpSent = true
        state.isAwaitingOtp = true

        let effect = handleAuthenticationSuccess(
            authId: "auth123",
            provider: "apple",
            email: "user@example.com",
            state: &state
        )

        #expect(state.isLoading == false)
        #expect(state.authenticationStatus == AuthFeature.AuthenticationStatus.loggedIn)
        #expect(state.errorMessage == nil)
        #expect(state.authenticationResult?.authId == "auth123")
        #expect(state.authenticationResult?.provider == "apple")
        #expect(state.authenticationResult?.isAuthenticated == true)
        #expect(state.authenticationResult?.email == "user@example.com")

        // Form states should be reset
        #expect(state.showingCustomLogin == false)
        #expect(state.showingCustomSignup == false)
        #expect(state.isAwaitingOtp == false)
        #expect(state.isOtpSent == false)
        #expect(state.email == "")
        #expect(state.username == "")
        #expect(state.password == "")
        #expect(state.confirmPassword == "")
        #expect(state.otpCode == "")

        // Effect should be none - we'll just verify it doesn't crash
    }

    @Test("handleAuthenticationSuccess helper function with empty authId")
    func handleAuthenticationSuccessEmptyAuthId() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.authenticated
        state.currentUserId = 123
        state.isLoading = true
        state.errorMessage = "Some error"
        state.authenticationResult = nil
        state.email = ""
        state.username = ""
        state.password = ""
        state.confirmPassword = ""
        state.showingCustomLogin = false
        state.showingCustomSignup = false
        state.otpCode = ""
        state.isOtpSent = false
        state.isAwaitingOtp = false

        let effect = handleAuthenticationSuccess(
            authId: "",
            provider: nil,
            email: nil,
            state: &state
        )

        #expect(state.isLoading == false)
        #expect(state.authenticationStatus == AuthFeature.AuthenticationStatus.guest)
        #expect(state.errorMessage == nil)
        #expect(state.authenticationResult?.authId == "")
        #expect(state.authenticationResult?.provider == nil)
        #expect(state.authenticationResult?.isAuthenticated == false)
        #expect(state.authenticationResult?.email == nil)

        // Effect should be none - we'll just verify it doesn't crash
    }

    @Test("prepareOtpFlow helper function")
    func prepareOtpFlowHelper() async {
        var state = AuthFeature.State()
        state.authenticationStatus = AuthFeature.AuthenticationStatus.guest
        state.currentUserId = nil
        state.isLoading = false
        state.errorMessage = nil
        state.authenticationResult = nil
        state.email = "test@example.com"
        state.username = ""
        state.password = ""
        state.confirmPassword = ""
        state.showingCustomLogin = false
        state.showingCustomSignup = false
        state.otpCode = ""
        state.isOtpSent = false
        state.isAwaitingOtp = false

        let effect = prepareOtpFlow(state: &state)

        #expect(state.isOtpSent == true)
        #expect(state.isAwaitingOtp == true)

        // This should call handleSendOtp which returns a .run effect
        // We'll just verify it doesn't crash and sets the state correctly
    }
}
