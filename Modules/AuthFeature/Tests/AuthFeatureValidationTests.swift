//
//  AuthFeatureValidationTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import ComposableArchitecture
import Testing

@Suite("Auth Feature Validation Tests")
@MainActor
struct AuthFeatureValidationTests {

    @Test("Custom sign up validation - missing email")
    func customSignUpMissingEmail() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Set username but leave email empty
        await store.send(.usernameChanged("testuser")) {
            $0.username = "testuser"
        }

        await store.send(.customSignUpTapped) {
            $0.errorMessage = "Please enter email and username"
        }
    }

    @Test("Custom sign up validation - missing username")
    func customSignUpMissingUsername() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Set email but leave username empty
        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.customSignUpTapped) {
            $0.errorMessage = "Please enter email and username"
        }
    }

    @Test("Custom sign up validation - username too short")
    func customSignUpUsernameTooShort() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.usernameChanged("ab")) {
            $0.username = "ab"
        }

        await store.send(.customSignUpTapped) {
            $0.errorMessage = "Username must be at least 3 characters"
        }
    }

    @Test("Custom sign up validation - valid inputs trigger OTP flow")
    func customSignUpValidInputs() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.usernameChanged("testuser")) {
            $0.username = "testuser"
        }

        await store.send(.customSignUpTapped) {
            $0.isOtpSent = true
            $0.isAwaitingOtp = true
            $0.isLoading = true
            $0.errorMessage = nil
        }

        // Should trigger OTP sending
        await store.receive(.setLoading(true))
        await store.receive(.authenticationFailed("Failed to send verification code. Please try again."))
    }

    @Test("Send OTP validation - missing email")
    func sendOtpMissingEmail() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.sendOtpTapped) {
            $0.errorMessage = "Please enter your email address"
        }
    }

    @Test("Send OTP validation - valid email")
    func sendOtpValidEmail() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.sendOtpTapped) {
            $0.isOtpSent = true
            $0.isAwaitingOtp = true
            $0.isLoading = true
            $0.errorMessage = nil
        }

        // Should trigger OTP sending
        await store.receive(.setLoading(true))
        await store.receive(.authenticationFailed("Failed to send verification code. Please try again."))
    }

    @Test("Verify OTP validation - missing email")
    func verifyOtpMissingEmail() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.otpCodeChanged("123456")) {
            $0.otpCode = "123456"
        }

        await store.send(.verifyOtpTapped) {
            $0.errorMessage = "Please enter the verification code"
        }
    }

    @Test("Verify OTP validation - missing OTP code")
    func verifyOtpMissingCode() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.verifyOtpTapped) {
            $0.errorMessage = "Please enter the verification code"
        }
    }

    @Test("Verify OTP validation - valid inputs")
    func verifyOtpValidInputs() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.otpCodeChanged("123456")) {
            $0.otpCode = "123456"
        }

        await store.send(.verifyOtpTapped) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        // Should trigger OTP verification
        await store.receive(.setLoading(true))
        await store.receive(.authenticationFailed("Invalid verification code. Please try again."))
    }

    @Test("Loading state prevents multiple operations")
    func loadingStatePreventsOperations() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        // Set loading state
        await store.send(.setLoading(true)) {
            $0.isLoading = true
        }

        // Set up valid inputs
        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.usernameChanged("testuser")) {
            $0.username = "testuser"
        }

        // Operations should be blocked by loading state
        await store.send(.customSignUpTapped)

        await store.send(.sendOtpTapped)

        await store.send(.verifyOtpTapped)
    }
}
