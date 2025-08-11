@testable import AuthFeature
import ComposableArchitecture
import Foundation
import DatabaseModule
import Testing

@Suite("Auth Feature Sign Up Tests", .serialized)
@MainActor
struct AuthSignUpTestsSeparate {
    @Test("Sign up success")
    func signUpSuccess() async { /* ...existing code... */ }
    @Test("Sign up failure")
    func signUpFailure() async { /* ...existing code... */ }
}
