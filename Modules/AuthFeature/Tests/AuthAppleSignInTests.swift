@testable import AuthFeature
import ComposableArchitecture
import Foundation
import DatabaseModule
import Testing

@Suite("Auth Feature Apple Sign In Tests", .serialized)
@MainActor
struct AuthAppleSignInTestsSeparate {
    @Test("Sign in with Apple success")
    func signInWithAppleSuccess() async { /* ...existing code... */ }
    @Test("Sign in with Apple failure")
    func signInWithAppleFailure() async { /* ...existing code... */ }
}
