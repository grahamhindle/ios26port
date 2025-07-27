@testable import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import Testing

@Suite("Auth Feature Sign Out Tests", .serialized)
@MainActor
struct AuthSignOutTestsSeparate {
    @Test("Sign out success")
    func signOutSuccess() async { /* ...existing code... */ }
}
