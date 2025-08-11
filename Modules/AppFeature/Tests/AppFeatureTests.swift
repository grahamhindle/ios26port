@testable import AppFeature
import ComposableArchitecture
import DatabaseModule
import Testing

@MainActor
struct AppFeatureTests {
    @Test("Initial state is correct")
    func initialState() {
        let state = AppFeature.State()
        #expect(state.user == nil)
        #expect(state.welcomeState == nil)
        #expect(state.authState == nil)
        #expect(state.onboardingState == nil)
        #expect(state.tabBarState == nil)
    }
}
