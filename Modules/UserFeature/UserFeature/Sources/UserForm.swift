import SharedModels
import SharedResources
import SharingGRDB
import StructuredQueriesGRDB
import SwiftUI

public struct UserForm: View {
    @State var user: User.Draft
    @State var authRecord: AuthenticationRecord.Draft?
    @State var profile: Profile.Draft?
    var onSave: ((User.Draft, AuthenticationRecord.Draft?, Profile.Draft?) -> Void)?

    @State private var enterBirthday: Bool = false
    @Environment(\.dismiss) var dismiss

    public init(user: User.Draft, authRecord: AuthenticationRecord.Draft? = nil, profile: Profile.Draft?, onSave saveHandler: ((User.Draft, AuthenticationRecord.Draft?, Profile.Draft?) -> Void)? = nil) {
        _user = State(initialValue: user)
        _authRecord = State(initialValue: authRecord)
        _profile = State(initialValue: profile)
        onSave = saveHandler
    }

    public var body: some View {
        Form {
            Section("User Information") {
                TextField("Name", text: $user.name)
                    .autocorrectionDisabled()
                TextField("Email", text: $user.email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                Toggle("Enter birthday", isOn: $enterBirthday)
                if enterBirthday, let dateBinding = Binding($user.dateOfBirth) {
                    DatePicker("Birthday", selection: dateBinding, displayedComponents: .date)
                }
            }

            Section("Authentication") {
                if let authRecord = authRecord {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(authRecord.isAuthenticated ? "Authenticated" : "Not Authenticated")
                            .foregroundColor(authRecord.isAuthenticated ? .green : .orange)
                    }

                    if let providerID = authRecord.providerID {
                        HStack {
                            Text("Provider")
                            Spacer()
                            Text(providerID)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("No authentication record")
                        .foregroundColor(.secondary)
                }

                Button(authRecord?.isAuthenticated == true ? "Re-authenticate" : "Login") {
                    // TODO: Integrate with login method
                }
                .disabled(user.name.isEmpty || user.email.isEmpty)
            }
           Section("Profile") {
                if let profile = profile {
                    HStack {
                        Text("Membership")
                        Spacer()
                        Text(profile.membershipStatus.rawValue)
                        .badge(profile.membershipStatus.rawValue)
                            .foregroundColor(Color(hex: profile.themeColorHex))
                    }
                    if let profileBinding = Binding($profile) {
                        ColorPicker("Theme", selection: Binding(
                            get: { profileBinding.wrappedValue.themeColorHex.swiftUIColor },
                            set: { profileBinding.wrappedValue.themeColorHex.swiftUIColor = $0 }
                        ))
                    }
////                    TextField("Theme Color", text: $profile.themeColorHex)
////                        .keyboardType(.numberPad)
////                        .onChange(of: profile.themeColorHex) { newValue in
////                            profile.themeColorHex = newValue
                                    }
                           }
        }
        //.navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {
                        dismiss()
                    }

            }
            ToolbarItem(placement: .confirmationAction) {

                Button("Save") {
                    onSave?(user, authRecord, profile)
                    dismiss()
                }
            }


        }
    }
}

#Preview {
//    let _ = prepareDependencies {
//        $0.defaultDatabase = try! appDatabase()
//    }

    NavigationStack {
        UserForm(
            user: User.Draft(
                name: "John Doe",
                email: "john@example.com"
            ),
            authRecord: AuthenticationRecord.Draft(
                isAuthenticated: false,
                providerID: "Google"
            ),
            profile: Profile.Draft(
                membershipStatus: .free, 
                authorizationStatus: .pending,
                themeColorHex: 0xFF5733_ff
            )
        )
    }
}
