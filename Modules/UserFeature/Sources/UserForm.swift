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
                    handleAuthenticationAction(user)
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

    private func handleAuthenticationAction(_ user: User.Draft) {
        if !user.isAuthenticated {
            // store.send(.signUp)
        } else if isRecentlySignedIn(user) {
            // store.send(.signOut)
        } else {
            // store.send(.signIn)
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
        UserForm(user: User.Draft(
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

        ))
    }
}

#Preview("Not Authenticated") {
    // _ = prepareDependencies {
    //     $0.defaultDatabase = try! appDatabase()
    // }

    NavigationStack {
        UserForm(user: User.Draft(
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

        ))
    }
}
