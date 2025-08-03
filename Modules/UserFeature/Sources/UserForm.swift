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
        _enterBirthday = State(initialValue: user.dateOfBirth != nil)
    }

    public var body: some View {
        Form {
            Section {
                TextField("Name", text: $user.name)
                    .autocorrectionDisabled()

                Toggle("Include birthday", isOn: $enterBirthday)
                    .onChange(of: enterBirthday) { _, newValue in
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
            authStore = authStoreFactory()
        }
        .onChange(of: authStore?.state.authenticationResult) { _, result in
            if let result = result {
                updateUserWithAuthResult(result)
                print("Auth result received: \(result)")
            }
        }

        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withErrorReporting {
                        // swiftlint:disable identifier_name
                        try database.write { db in
                            try User.upsert { user }
                                .execute(db)
                            // swiftlint:enable identifier_name
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

        performAuthentication()
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
            // swiftlint:disable identifier_name
            try database.write { db in
                try User.upsert { user }
                    .execute(db)
                // swiftlint:enable identifier_name
            }
        }
    }

    private func isRecentlySignedIn(_ user: User.Draft) -> Bool {
        guard let lastSignedIn = user.lastSignedInDate else { return false }
        let hoursSinceSignIn = Date().timeIntervalSince(lastSignedIn) / 3600
        return hoursSinceSignIn < 24
    }
}

struct UserForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Authenticated preview
            let _ = prepareDependencies {
                // swiftlint:disable force_try
                $0.defaultDatabase = try! appDatabase()
                // swiftlint:enable force_try
            }
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
            .previewDisplayName("Authenticated")
            
            // Not authenticated preview
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
            .previewDisplayName("Not Authenticated")
        }
    }
}
