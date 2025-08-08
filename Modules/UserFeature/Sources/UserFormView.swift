import ComposableArchitecture
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI

public struct UserFormView: View {
    let store: StoreOf<UserFormFeature>

    public init(store: StoreOf<UserFormFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Name", text: viewStore.binding(get: \.draft.name, send: { .binding(.set(\.draft.name, $0)) }))
                        .autocorrectionDisabled()

                    Toggle("Include birthday", isOn: viewStore.binding(get: \.enterBirthday, send: { .binding(.set(\.enterBirthday, $0)) }))
                        .onChange(of: viewStore.enterBirthday) { _, newValue in
                            viewStore.send(.enterBirthdayToggled(newValue))
                        }

                    if viewStore.enterBirthday {
                        DatePicker("Birthday",
                                   selection: viewStore.binding(get: { $0.draft.dateOfBirth ?? Date() },
                                                                send: { .binding(.set(\.draft.dateOfBirth, $0)) }),
                                   displayedComponents: .date)
                    }
                } header: {
                    Text("Personal Info")
                }

                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(viewStore.draft.isAuthenticated ? "Authenticated" : "Not Authenticated")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundColor(.white)
                            .background(viewStore.draft.isAuthenticated ? .green : .orange)
                            .cornerRadius(10)
                    }

                    if let providerID = viewStore.draft.providerID {
                        HStack {
                            Text("Provider")
                            Spacer()
                            Text(providerID)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(viewStore.authenticationButtonTitle) {
                        viewStore.send(.authenticationButtonTapped)
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
                            Text("\(viewStore.draft.membershipStatus.rawValue) \(Image(systemName: "star"))")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(hex: viewStore.draft.membershipStatus.color))
                                .cornerRadius(10)
                        }
                    }
                    ColorPicker("Theme", selection: viewStore.binding(
                        get: { Color(hex: $0.draft.themeColorHex) },
                        send: { .binding(.set(\.draft.themeColorHex, $0.hexValue)) }
                    ))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewStore.send(.cancelTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewStore.send(.saveTapped)
                    }
                }
            }
            .overlay(alignment: .top) {
                if viewStore.showingSuccessMessage {
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
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewStore.showingSuccessMessage)
                }
            }
        }
    }
}

struct UserFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Authenticated preview
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
                            lastSignedInDate: Date(),
                            authId: "guest|guest_user_temp",
                            isAuthenticated: false,
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
            .previewDisplayName("Not Authenticated")
        }
    }
}
