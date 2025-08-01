import AuthFeature
import ComposableArchitecture
import SharedModels
import SharedResources
import SharingGRDB

import SwiftUI

public struct UserForm: View {
    @Dependency(\.defaultDatabase) var database
    @State private var enterBirthday: Bool = false
    @Environment(\.dismiss) var dismiss
    @State var user: User.Draft
    
    @Dependency(\.authStoreFactory) var authStoreFactory
    @State private var authStore: StoreOf<AuthFeature>?

    public init(user: User.Draft) {
        self.user = user
        self._enterBirthday = State(initialValue: user.dateOfBirth != nil)
    }

    public var body: some View {
        
            Form {
            Section {
                TextField("Name", text: $user.name)
                    .autocorrectionDisabled()

                Toggle("Include birthday", isOn: $enterBirthday)
                    .onChange(of: enterBirthday) {oldValue, newValue in
                        if newValue && user.dateOfBirth == nil {
                            user.dateOfBirth = Date()
                        } else if !newValue {
                            user.dateOfBirth = nil
                        }
                    }

                if enterBirthday, let dateBinding = Binding($user.dateOfBirth) {
                    DatePicker("Birthday", selection: dateBinding, displayedComponents: .date)
                }
            } header: {
                Text("Personal Info")
            }

            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(user.isAuthenticated ? "Authenticated" : "Not Authenticated")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                        .background(user.isAuthenticated ? .green : .orange)
                        .cornerRadius(10)
                }

                if let providerID = user.providerID {
                    HStack {
                        Text("Provider")
                        Spacer()
                        Text(providerID)
                            .foregroundColor(.secondary)
                    }
                }
                Button(buttonTitle(user)) {
                    handleAuthenticationAction()
                }
            } header: {
                Text("Authentication")
            }
            Section {
                HStack {
                    Text("Membership")
                    Spacer()
                    Button {
                        //
                    } label: {
                        Text("\(user.membershipStatus.rawValue) \(Image(systemName: "star"))")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: user.membershipStatus.color))
                            .cornerRadius(10)
                    }
                }
                ColorPicker("Theme", selection: $user.themeColorHex.swiftUIColor)
            }
            }
            .onAppear {
                if authStore == nil {
                    authStore = authStoreFactory()
                }
            }
            .onChange(of: authStore?.state.authenticationResult) { _, result in
                if let result = result {
                    updateUserWithAuthResult(result)
                    print("Auth result received: \(result)")
                }
            }
//            .onChange(of: viewStore.state) { _, authResult in
//                print("onChange triggered with authResult: \(String(describing: authResult))")
//                if let authResult = authResult {
//                    // Check for session conflict: user record says not authenticated, but Auth0 session exists
//                    if !user.isAuthenticated && authResult.isAuthenticated {
//                        // Show alert asking if they want to use existing session or clear it
//                        print("Session conflict detected - existing Auth0 session found")
//                        // For now, just clear session and proceed with signup
//                        clearSessionAndSignUp()
//                    } else if !user.isAuthenticated && !authResult.isAuthenticated {
//                        // No conflict - proceed with signup
//                        print("No session conflict - proceeding with signup")
//                        authStore.send(.signUp)
//                    } else {
//                        print("Updating user with auth result")
//                        updateUserWithAuthResult(authResult)
//                    }
//                }
//            }
            .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withErrorReporting {
                        try database.write { db in
                            try User.upsert { user }
                                .execute(db)
                        }
                    }
                    dismiss()
                }
            }
            
        }
    }

    private func buttonTitle(_ user: User.Draft) -> String {
        if !user.isAuthenticated {
            return "Sign Up"
        } else if isRecentlySignedIn(user) {
            return "Sign Out"
        } else {
            return "Sign In"
        }
    }

    private func handleAuthenticationAction() {


        guard let authStore = authStore else { 
            print("authStore is nil, returning")
            return 
        }
        print("handleAuthenticationAction: isAuthenticated = \(user.isAuthenticated)")

        // Temporarily disable clearSession to test if it's causing the issue
        // #if targetEnvironment(simulator)
        // print("Running in simulator - calling clearSession first")
        // authStore.send(.clearSession)
        // 
        // // Wait a moment for clearSession to complete before starting auth flow
        // Task {
        //     try? await Task.sleep(for: .milliseconds(500))
        //     await MainActor.run {
        //         performAuthentication()
        //     }
        // }
        // #else
        // print("Not running in simulator - skipping clearSession")
        performAuthentication()
        // #endif
        
        // Note: Auth result will be handled by .onChange modifier
    }
    
    private func performAuthentication() {
        guard let authStore = authStore else { 
            print("performAuthentication: authStore is nil")
            return 
        }
        
        if !user.isAuthenticated {
            print("performAuthentication: sending .signUp action")
            authStore.send(.signUp)
        } else if user.isAuthenticated && isRecentlySignedIn(user) {
            print("performAuthentication: sending .signOut action")
            authStore.send(.signOut)
        } else {
            print("performAuthentication: sending .signIn action")
            authStore.send(.signIn)
        }
        
        print("performAuthentication: action sent, current loading state: \(authStore.state.isLoading)")
    }
    
    
    
    private func updateUserWithAuthResult(_ authResult: AuthFeature.AuthenticationResult) {
        user.authId = authResult.authId
        user.isAuthenticated = authResult.isAuthenticated
        user.providerID = authResult.provider
        user.email = authResult.email
        user.lastSignedInDate = authResult.isAuthenticated ? Date() : nil
        
        // Save to database - this will trigger reactive updates
        withErrorReporting {
            try database.write { db in
                try User.upsert { user }
                    .execute(db)
            }
        }
    }

    private func isRecentlySignedIn(_ user: User.Draft) -> Bool {
        guard let lastSignedIn = user.lastSignedInDate else { return false }
        let hoursSinceSignIn = Date().timeIntervalSince(lastSignedIn) / 3600
        return hoursSinceSignIn < 24
    }
}

#Preview("Authenticated") {
    // let _ = prepareDependencies {
    //     $0.defaultDatabase = try! appDatabase()
    // }
    

    NavigationStack {
        UserForm(
            user: User.Draft(
                name: "Guest User",
                dateOfBirth: Date(),
                dateCreated: Date(),
                lastSignedInDate: Date(),
                authId: "guest|guest_user_temp",
                isAuthenticated: true,
                providerID: "guest",
                membershipStatus: .free,
                authorizationStatus: .guest,
                themeColorHex: 0x28A7_45FF,
                profileCreatedAt: Date()
            )
        )
    }
}

#Preview("Not Authenticated") {
    // _ = prepareDependencies {
    //     $0.defaultDatabase = try! appDatabase()
    // }
    


    NavigationStack {
        UserForm(
            user: User.Draft(
                name: "Guest User",
                dateOfBirth: nil,
                dateCreated: Date(),
                lastSignedInDate: Date(),
                authId: "guest|guest_user_temp",
                isAuthenticated: false,
                providerID: "guest",
                membershipStatus: .free,
                authorizationStatus: .guest,
                themeColorHex: 0x28A7_45FF,
                profileCreatedAt: Date()
            )
        )
    }
}
