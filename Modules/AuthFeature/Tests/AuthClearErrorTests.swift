@testable import AuthFeature
import ComposableArchitecture
import Foundation
import SharedModels
import Testing

@Suite("Auth Feature Clear Error Tests", .serialized)
@MainActor
struct AuthClearErrorTestsSeparate {
    @Test("Clear error")
    func clearError() async { /* ...existing code... */ }
}
