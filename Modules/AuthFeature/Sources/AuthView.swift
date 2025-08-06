import ComposableArchitecture
import SharedModels
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

            Text("Auth.id: \(store.state.authenticationResult?.authId ?? "No Auth.id")")
            Text("Auth.provider: \(store.state.authenticationResult?.provider ?? "No Auth.provider")")
            Text("Auth.isAuthenticated: \(store.state.authenticationResult?.isAuthenticated ?? false)")
            Text("Auth.email: \(store.state.authenticationResult?.email ?? "No Auth.email")")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    AuthView(store: Store(initialState: AuthFeature.State()) {
        AuthFeature()
    })
}
