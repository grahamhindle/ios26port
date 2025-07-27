@testable import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import Testing

@Suite("Auth Feature Anonymous Tests", .serialized)
@MainActor
struct AuthAnonymousTestsSeparate {
    @Test("Sign in anonymously success")
    func signInAnonymouslySuccess() async { /* ...existing code... */ }
    @Test("Sign in anonymously failure")
    func signInAnonymouslyFailure() async { /* ...existing code... */ }
    @Test("Anonymous user can upgrade to full account")
    func anonymousUserUpgrade() async { /* ...existing code... */ }
}
