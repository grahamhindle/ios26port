import ComposableArchitecture
import DatabaseModule
import SwiftUI

public struct AuthView: View {
    @Bindable var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            Button("Clear Session") {
                store.send(.clearSession)
            }
            Text("Authentication Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            Button("Sign In") {
                // store.send(.clearSession)
                store.send(.signIn)
            }
            Button("Sign Up") {
                // store.send(.clearSession)
                store.send(.signUp)
            }
            Button("Sign In as Guest") {
                // store.send(.clearSession)
                store.send(.signInAsGuest)
            }
            Button("Sign Out") {
                store.send(.signOut)
            }

            Text("AuthId: \(String(describing: store.authenticationResult?.authId))")
            Text("AuthId: \(String(describing: store.authenticationResult?.email))")

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("AuthView") {
    AuthView(store: Store(initialState: AuthFeature.State()) {
        AuthFeature()
    })
}
