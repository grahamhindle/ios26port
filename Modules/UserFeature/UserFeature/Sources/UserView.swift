
import Charts
import SharedModels
import SharingGRDB
import SwiftUI

public struct UserView: View {
    @Bindable var model: UserModel
    @State private var editingUserIndex: Int?

    public init(model: UserModel) {
        self.model = model
    }

    private func addNewUser() {
        editingUserIndex = -1 // -1 indicates new user
    }

    @ViewBuilder
    private func sheetContent() -> some View {
        NavigationStack {
            if let index = editingUserIndex {
                if index == -1 {
                    // New user
                    let (userDraft, authDraft, profileDraft) = model.addNewUser()
                    UserForm(
                        user: userDraft,
                        authRecord: authDraft,
                        profile: profileDraft,
                        onSave: { savedUser, savedAuthRecord, savedProfile in
                            Task {
                                await model.createUserWithRelations(savedUser, authRecord: savedAuthRecord, profile: savedProfile)
                            }
                        }
                    )
                    .navigationTitle("New User")
                } else if index < model.userProfileAuth.count {
                    // Edit existing user - use live data from model
                    let row = model.userProfileAuth[index]
                    let userDraft = User.Draft(row.user)
                    let authDraft = row.authRecord.map { AuthenticationRecord.Draft($0) }
                    let profileDraft = row.profile.map { Profile.Draft($0) }

                    UserForm(
                        user: userDraft,
                        authRecord: authDraft,
                        profile: profileDraft,
                        onSave: { savedUser, savedAuthRecord, savedProfileRecord in
                            Task {
                                await model.updateUser(savedUser)
                                if let authRecord = savedAuthRecord {
                                    await model.updateAuthenticationRecord(authRecord)
                                }
                                if let profile = savedProfileRecord {
                                    await model.updateProfile(profile)
                                }
                            }
                        }
                    )
                    .navigationTitle("Edit User")
                }
            }
        }
        // .presentationDetents([.medium])
    }

    public var body: some View {
        List {
            Section {
                // Top-level statstuist build
            }
            Section {
                ForEach(model.userProfileAuth, id: \.user.id) { row in
                    if row.authRecord?.isAuthenticated == true {
                        UserRow(row: row)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.deleteButtonTapped(user: row.user, auth: row.authRecord, profile: row.profile)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                Button {
                                    if let index = model.userProfileAuth.firstIndex(where: { $0.user.id == row.user.id }) {
                                        editingUserIndex = index
                                    }
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                .disabled(model.userProfileAuth.isEmpty)
                            }
                    }
                }

            } header: {
                Text("Authenticated Users")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
            Section {
                ForEach(model.userProfileAuth, id: \.user.id) { row in
                    if row.authRecord?.isAuthenticated == false {
                        UserRow(row: row)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.deleteButtonTapped(user: row.user, auth: row.authRecord, profile: row.profile)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                Button {
                                    if let index = model.userProfileAuth.firstIndex(where: { $0.user.id == row.user.id }) {
                                        editingUserIndex = index
                                    }
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                .disabled(model.userProfileAuth.isEmpty)
                            }
                    }
                } // Character options
            } header: {
                Text("Guests")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
        }
        .searchable(text: .constant(""))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: addNewUser) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New User")
                        }
                        .bold()
                        .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { editingUserIndex != nil },
            set: { if !$0 { editingUserIndex = nil } }
        )) {
            sheetContent()
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    NavigationStack {
        UserView(model: UserModel())
    }
}
