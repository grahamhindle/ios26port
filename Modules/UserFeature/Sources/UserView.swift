import Charts
import SharedModels
import SharingGRDB
import SwiftUI

public struct UserView: View {
    // @FetchAll(
    //     User
    //         .order(by: \.name)

    // ) public var users: [User]
    @Bindable var model: UserModel

    public init(model: UserModel) {
        self.model = model
    }

    @State private var filterSelection: UserFilter = .all

    enum UserFilter: String, CaseIterable {
        case all = "All"
        case authenticated = "Authenticated"
        case guests = "Guests"
    }

    private var filteredUsers: [User] {
        switch filterSelection {
        case .all:
            return model.users
        case .authenticated:
            return model.users.filter { $0.isAuthenticated }
        case .guests:
            return model.users.filter { !$0.isAuthenticated }
        }
    }

    private var recentlyActiveUsers: Int {
        model.users.filter { user in
            guard let lastSignedIn = user.lastSignedInDate else { return false }
            let hoursSinceSignIn = Date().timeIntervalSince(lastSignedIn) / 3600
            return hoursSinceSignIn < 24
        }.count
    }

    private var sectionTitle: String {
        switch filterSelection {
        case .all:
            return "All Users"
        case .authenticated:
            return "Authenticated Users"
        case .guests:
            return "Guest Users"
        }
    }

    public var body: some View {
        List {
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    // Total Users Card
                    StatCard(
                        title: "Total Users",
                        value: "\(model.users.count)",
                        icon: "person.2.fill",
                        color: .blue
                    )

                    // Filtered Users Card
                    StatCard(
                        title: "Guest users",
                        value: "\(model.users.filter { !$0.isAuthenticated }.count)",
                        icon: "line.3.horizontal.decrease.circle.fill",
                        color: .orange
                    )

                    // Authenticated Users Card
                    StatCard(
                        title: "Authenticated",
                        value: "\(model.users.filter { $0.isAuthenticated }.count)",
                        icon: "checkmark.shield.fill",
                        color: .green
                    )

                    // Recent Activity Card
                    StatCard(
                        title: "Recent Activity",
                        value: "\(recentlyActiveUsers)",
                        icon: "clock.fill",
                        color: .purple
                    )
                }
                .padding(.vertical, 8)
            }
            header: {
                Text("User Stats")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }

            Section {
                // Filter Picker
                Picker("Filter Users", selection: $filterSelection) {
                    ForEach(UserFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
            } header: {
                Text("Filter Users")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }

            Section {
                ForEach(filteredUsers, id: \.id) { user in
                    UserRow(user: user)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                model.deleteButtonTapped(user: user)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button {
                                model.editButtonTapped(user: user)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            .disabled(user.name.isEmpty)
                        }
                }
            } header: {
                HStack {
                    Text(sectionTitle)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)

                    Spacer()

                    Text("\(filteredUsers.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .searchable(text: .constant(""))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        model.addUserButtonTapped()
                    } label: {
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
        .sheet(item: $model.userForm)  { user in
            NavigationStack {
                UserForm(user: user)
                    .navigationTitle("New User")
            }
        }
    }
}

// MARK: - StatCard Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = prepareDependencies {        
                $0.defaultDatabase = try! appDatabase()
        }
        NavigationStack {
            UserView(model: UserModel())
        }
    }
}
