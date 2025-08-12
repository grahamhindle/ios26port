import AuthFeature
import ComposableArchitecture
import DatabaseModule
import SharedResources
import SharingGRDB
import SwiftUI

public struct UserFormView: View {
    @Bindable var store: StoreOf<UserFormFeature>

    public init(store: StoreOf<UserFormFeature>) {
        self.store = store
    }

    public var body: some View {
            Form {
                Section {
                    HStack {
                        Text("Full Name")
                        TextField("", text: $store.draft.name)
                        .autocorrectionDisabled()
                    }

                    HStack {
                        Text("Nickname")
                        TextField("", text: $store.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    }

                    Toggle("Include birthday", isOn: $store.enterBirthday)
                    .onChange(of: store.enterBirthday) { _, newValue in
                        store.send(.enterBirthdayToggled(newValue))
                    }

                    if store.enterBirthday {
                        DatePicker("Birthday",
                                   selection: Binding(
                                       get: { store.draft.dateOfBirth ?? Date() },
                                       set: { store.draft.dateOfBirth = $0 }
                                   ),
                                   displayedComponents: .date)
                    }
                } header: {
                    Text("Personal Info")
                }

                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        HStack(spacing: 4) {
                            Text(store.draft.isAuthenticated ? "Authenticated" : "Not Authenticated")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                                .background(store.draft.isAuthenticated ? .green : .orange)
                                .cornerRadius(10)
                            
                            Button(action: {
                                store.send(.statusInfoTapped)
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if store.draft.isAuthenticated && store.isRecentlySignedIn {
                        // Authenticated and recently signed in - show sign out
                        Text("Sign Out?")
                            .anyButton(.callToAction) {
                            store.send(.auth(.signOut))
                        }
                        .foregroundColor(.red)
                    } else if store.draft.isAuthenticated && !store.isRecentlySignedIn {
                        // Authenticated but not recently signed in - show sign in options
                        Button("Sign In") {
                            store.send(.auth(.signIn))
                        }
                        
                        Button(action: { store.send(.auth(.signInWithApple)) }) {
                            SignInWithAppleButtonView()
                                .frame(height: 50)
                        }
                        .accessibilityLabel("Continue with Apple")

                        Button(action: { store.send(.auth(.signInWithGoogle)) }) {
                            SignInWithGoogleButtonView()
                                .frame(height: 50)
                        }
                        .accessibilityLabel("Continue with Google")
                    } else {
                        // Not authenticated - show sign up options only
                        Text("Sign Up")
                            .anyButton(.callToAction){
                            store.send(.auth(.showCustomSignup))
                        }
                        
                        Button(action: { store.send(.auth(.signInWithApple)) }) {
                            SignInWithAppleButtonView()
                                .frame(height: 50)
                        }
                        .accessibilityLabel("Sign up with Apple")


                        Button(action: { store.send(.auth(.signInWithGoogle)) }) {
                            SignInWithGoogleButtonView()
                                .frame(height: 50)
                        }
                        .accessibilityLabel("Continue with Google")
                    }
                } header: {
                    Text("Authentication")
                }

                Section {
                    HStack {
                        Text("Membership")
                        Spacer()
                        Button {
                            // TODO: Handle membership changes
                        } label: {
                            Text("\(store.draft.membershipStatus.rawValue) \(Image(systemName: "star"))")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(hex: store.draft.membershipStatus.color))
                                .cornerRadius(10)
                        }
                    }
                    ColorPicker("Theme", selection: Binding(
                        get: { Color(hex: store.draft.themeColorHex) },
                        set: { store.draft.themeColorHex = $0.hexValue }
                    ))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveTapped)
                    }
                }
            }
            .overlay(alignment: .top) {
                if store.showingSuccessMessage {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Profile updated successfully")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.showingSuccessMessage)
                }
            }
            .sheet(item: Binding(
                get: { store.auth.authSheet },
                set: { _ in store.send(.auth(.hideCustomForms)) }
            )) { sheet in
                AuthView(store: store.scope(state: \.auth, action: \.auth))
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .overlay(alignment: .center) {
                if store.showingStatusInfo {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.draft.isAuthenticated ? 
                            "You're signed in! Your data is securely backed up and synced across devices." :
                            "Sign up to backup your data, sync across devices, and access premium features."
                        )
                        .font(.caption)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .background(.regularMaterial)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .frame(maxWidth: 280)
                    .offset(y: -200) // Adjust this value to position over status row
                    .zIndex(10)
                    .onTapGesture {
                        store.send(.statusInfoTapped)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.2), value: store.showingStatusInfo)
                }
            }
    }
}

struct UserFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Authenticated preview
            // swiftlint:disable redundant_discardable_let
            let _ = prepareDependencies {
                // swiftlint:disable force_try
                $0.defaultDatabase = try! appDatabase()
                // swiftlint:enable force_try
            }
            NavigationStack {
                UserFormView(
                    store: Store(initialState: UserFormFeature.State(
                        draft: User.Draft(
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
                    )) {
                        UserFormFeature()
                    }
                )
            }
            .previewDisplayName("Authenticated")

            // Not authenticated preview
            NavigationStack {
                UserFormView(
                    store: Store(initialState: UserFormFeature.State(
                        draft: User.Draft(
                            name: "Guest User",
                            dateOfBirth: nil,
                            dateCreated: Date(),
                            lastSignedInDate: nil,
                            authId: nil,
                            isAuthenticated: false,
                            providerID: nil,
                            membershipStatus: .free,
                            authorizationStatus: .guest,
                            themeColorHex: 0x28A7_45FF,
                            profileCreatedAt: Date()
                        )
                    )) {
                        UserFormFeature()
                    }
                )
            }
            .previewDisplayName("Not Authenticated")
        }
    }
}
