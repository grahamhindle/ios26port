@testable import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@Suite("Auth Feature Sign In Tests", .serialized)
@MainActor
struct AuthSignInTestsSeparate {
    @Test("Feature initializes with correct state")
    func initialState() async { /* ...existing code... */ }
    @Test("Sign in success")
    func signInSuccess() async { /* ...existing code... */ }
    @Test("Sign in failure")
    func signInFailure() async { /* ...existing code... */ }
}
