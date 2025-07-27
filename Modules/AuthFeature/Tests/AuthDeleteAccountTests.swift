@testable import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import Testing

@Suite("Auth Feature Delete Account Tests", .serialized)
@MainActor
struct AuthDeleteAccountTestsSeparate {
    @Test("Delete account success")
    func deleteAccountSuccess() async { /* ...existing code... */ }
    @Test("Delete account failure")
    func deleteAccountFailure() async { /* ...existing code... */ }
}
