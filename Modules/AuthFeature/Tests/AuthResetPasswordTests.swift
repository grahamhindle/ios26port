@testable import AuthFeature
import ComposableArchitecture
import Foundation
import DatabaseModule
import Testing

@Suite("Auth Feature Reset Password Tests", .serialized)
@MainActor
struct AuthResetPasswordTestsSeparate {
    @Test("Reset password success")
    func resetPasswordSuccess() async { /* ...existing code... */ }
    @Test("Reset password failure")
    func resetPasswordFailure() async { /* ...existing code... */ }
}
