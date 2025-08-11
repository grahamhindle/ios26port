@testable import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@Suite("Auth Feature Clear Error Tests", .serialized)
@MainActor
struct AuthClearErrorTestsSeparate {
    @Test("Clear error")
    func clearError() async { /* ...existing code... */ }
}
