//
//  AuthFeatureInitializationTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import ComposableArchitecture
import Testing

@Suite("Auth Feature Initialization Tests")
@MainActor
struct AuthFeatureInitializationTests {
    
    @Test("Initial state is correctly set")
    func initialState() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }
        
        #expect(store.state.authenticationStatus == AuthFeature.AuthenticationStatus.guest)
        #expect(store.state.currentUserId == nil)
        #expect(store.state.isLoading == false)
        #expect(store.state.errorMessage == nil)
        #expect(store.state.authenticationResult == nil)
        #expect(store.state.email == "")
        #expect(store.state.username == "")
        #expect(store.state.password == "")
        #expect(store.state.confirmPassword == "")
        #expect(store.state.showingCustomLogin == false)
        #expect(store.state.showingCustomSignup == false)
        #expect(store.state.otpCode == "")
        #expect(store.state.isOtpSent == false)
        #expect(store.state.isAwaitingOtp == false)
        #expect(store.state.authSheet == nil)
    }
    
    @Test("AuthSheet computed property works correctly")
    func authSheetComputedProperty() async {
        var state = AuthFeature.State()
        
        // No sheet initially
        #expect(state.authSheet == nil)
        
        // Login sheet
        state.showingCustomLogin = true
        #expect(state.authSheet == AuthFeature.AuthSheet.login)
        
        // Signup sheet
        state.showingCustomLogin = false
        state.showingCustomSignup = true
        #expect(state.authSheet == AuthFeature.AuthSheet.signup)
        
        // OTP sheet
        state.showingCustomSignup = false
        state.isAwaitingOtp = true
        #expect(state.authSheet == AuthFeature.AuthSheet.otp)
        
        // Multiple flags - OTP takes precedence
        state.showingCustomLogin = true
        state.showingCustomSignup = true
        state.isAwaitingOtp = true
        #expect(state.authSheet == AuthFeature.AuthSheet.otp)
    }
    
    @Test("AuthSheet enum properties")
    func authSheetEnum() async {
        #expect(AuthFeature.AuthSheet.login.id == "login")
        #expect(AuthFeature.AuthSheet.signup.id == "signup")
        #expect(AuthFeature.AuthSheet.otp.id == "otp")
    }
    
    @Test("AuthenticationResult initialization")
    func authenticationResult() async {
        let result = AuthFeature.AuthenticationResult(
            authId: "test-id",
            provider: "apple",
            isAuthenticated: true,
            email: "test@example.com"
        )
        
        #expect(result.authId == "test-id")
        #expect(result.provider == "apple")
        #expect(result.isAuthenticated == true)
        #expect(result.email == "test@example.com")
    }
    
    @Test("AuthenticationStatus cases")
    func authenticationStatus() async {
        let guestStatus = AuthFeature.AuthenticationStatus.guest
        let authenticatedStatus = AuthFeature.AuthenticationStatus.authenticated
        let loggedInStatus = AuthFeature.AuthenticationStatus.loggedIn
        
        // Just ensure they exist and are different
        #expect(guestStatus != authenticatedStatus)
        #expect(authenticatedStatus != loggedInStatus)
        #expect(guestStatus != loggedInStatus)
    }
}