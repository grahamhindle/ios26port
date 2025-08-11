@testable import AuthFeature
import ComposableArchitecture
import Foundation
import DatabaseModule
import Testing

@Suite("Auth Feature Auth State Changes Tests", .serialized)
@MainActor
struct AuthAuthStateChangesTestsSeparate {
    @Test("Auth state changes")
    func authStateChanges() async { /* ...existing code... */ }
}
