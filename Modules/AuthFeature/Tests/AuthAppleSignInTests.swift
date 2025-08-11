@testable import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import Testing

@Suite("Auth Feature Apple Sign In Tests", .serialized)
@MainActor
struct AuthAppleSignInTestsSeparate {
    @Test("Apple Sign In creates complete User record")
    func appleSignInCreatesCompleteUserRecord() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .mock
        }

        await store.send(.appleAuth(.signInTapped)) {
            $0.user = nil
            $0.hasExistingAccount = false
            $0.error = nil
            $0.appleAuth.isLoading = true
            $0.appleAuth.error = nil
        }

        await store.skipReceivedActions()

        // Verify final state after all actions complete
        guard let finalUser = store.state.user else {
            #expect(Bool(false), "User should exist after sign in")
            return
        }
        #expect(!finalUser.id.isEmpty)
        #expect(finalUser.userId != nil)
        #expect(finalUser.email == "user@example.com")
        #expect(finalUser.displayName == "Mock User")
        #expect(finalUser.isEmailVerified == true)
        #expect(finalUser.isAnonymous == false)
        #expect(finalUser.providerID == "password")
        #expect(finalUser.dateCreated != nil)
        #expect(finalUser.lastSignedInDate != nil)
        #expect(finalUser.didCompleteOnboarding == false)
        #expect(finalUser.themeColorHex == nil)

        // Verify auth state is properly updated
        #expect(store.state.hasExistingAccount == true)
        #expect(store.state.error == nil)
        #expect(store.state.appleAuth.isLoading == false)
        #expect(store.state.appleAuth.error == nil)
        #expect(store.state.emailAuth.hasExistingAccount == true)
        #expect(store.state.emailAuth.isSignupMode == false)
    }

}
