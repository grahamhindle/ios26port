import AuthFeature
import ComposableArchitecture
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
    let store: StoreOf<AuthFeature> = Store(initialState: AuthFeature.State()) { AuthFeature()}
    let userModel: UserModel

    @State private var enterBirthday: Bool = false
    @Environment(\.dismiss) var dismiss

    public init(user: User.Draft, authRecord: AuthenticationRecord.Draft? = nil, profile: Profile.Draft?, userModel: UserModel, onSave saveHandler: ((User.Draft, AuthenticationRecord.Draft?, Profile.Draft?) -> Void)? = nil) {
        _user = State(initialValue: user)
        _authRecord = State(initialValue: authRecord)
        _profile = State(initialValue: profile)
        self.userModel = userModel
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
                
                Button(buttonTitle(for: authRecord)) {
                    handleAuthenticationAction(for: authRecord)
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
                }
            }
        }
        .onChange(of: store.authenticationResult) { _, result in
            if let result = result {
                handleAuthenticationResult(result)
            }
        }
        // .navigationBarTitleDisplayMode(.inline)
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
    
    private func buttonTitle(for authRecord: AuthenticationRecord.Draft?) -> String {
        guard let authRecord = authRecord else { return "Sign Up" }
        
        if !authRecord.isAuthenticated {
            return "Sign Up"
        } else if isRecentlySignedIn() {
            return "Sign Out"
        } else {
            return "Sign In"
        }
    }
    
    private func handleAuthenticationAction(for authRecord: AuthenticationRecord.Draft?) {

        
        guard let authRecord = authRecord else {
            store.send(.signUp)
            return
        }
        
        if !authRecord.isAuthenticated {
            store.send(.signUp)
        } else if isRecentlySignedIn() {
            store.send(.signOut)
        } else {
            store.send(.signIn)
        }
    }
    
    private func isRecentlySignedIn() -> Bool {
        guard let lastSignedIn = user.lastSignedInDate else { return false }
        let hoursSinceSignIn = Date().timeIntervalSince(lastSignedIn) / 3600
        return hoursSinceSignIn < 24
    }
    
    private func handleAuthenticationResult(_ result: AuthFeature.AuthenticationResult) {
        Task {
            // Update AuthenticationRecord
            let authDraft = AuthenticationRecord.Draft(
                authId: result.authId.isEmpty ? nil : result.authId,
                isAuthenticated: result.isAuthenticated,
                providerID: result.provider
            )
            await userModel.updateAuthenticationRecord(authDraft)
            
            // Update User's lastSignedInDate
            let userDraft = User.Draft(

                lastSignedInDate: result.isAuthenticated ? Date() : nil
            )
            await userModel.updateUser(userDraft)
            
            // Update local state
            authRecord = authDraft
            user.lastSignedInDate = result.isAuthenticated ? Date() : nil
        }
    }
}

// #Preview {
////    let _ = prepareDependencies {
////        $0.defaultDatabase = try! appDatabase()
////    }
//
//    NavigationStack {
//        UserForm(
//            user: User.Draft(
//                name: "John Doe",
//                email: "john@example.com"
//            ),
//            authRecord: AuthenticationRecord.Draft(
//                isAuthenticated: false,
//                providerID: "Google"
//            ),
//            profile: Profile.Draft(
//                membershipStatus: .free,
//                authorizationStatus: .pending,
//                themeColorHex: 0xFF5733_ff
//            ),
//            store: Store(initialState: AuthFeature.State()) {
//                AuthFeature()
//            }
//        )
//    }
// }
