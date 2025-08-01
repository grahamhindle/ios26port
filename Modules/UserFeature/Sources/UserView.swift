import Charts
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI

public struct UserView: View {
    @Bindable var model: UserModel



    public init(model: UserModel) {
        self._model = Bindable(model)
    }

    


    public var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    // Users Group - 2 rows of 2 cells each
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            UserGridCell(
                                color: .green,
                                count: model.stats.allCount,
                                iconName: "person.3.fill",
                                title: "All Users"
                            ) {
                                model.detailTapped(detailType: .all)
                            }
                            
                            UserGridCell(
                                color: .blue,
                                count: model.stats.todayCount,
                                iconName: "calendar.circle.fill",
                                title: "Today"
                            ) {
                                model.detailTapped(detailType: .todayUsers)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            UserGridCell(
                                color: .orange,
                                count: model.stats.authenticated,
                                iconName: "checkmark.shield.fill",
                                title: "Authenticated"
                            ) {
                                model.detailTapped(detailType: .authenticated)
                            }
                            
                            UserGridCell(
                                color: .gray,
                                count: model.stats.guests,
                                iconName: "person.crop.circle.dashed",
                                title: "Guests"
                            ) {
                                model.detailTapped(detailType: .guests)
                            }
                        }
                    }
                    
                    // Membership Status Group - 3 cells in one row
                    VStack(spacing: 8) {
                        Text("Membership Status")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                        
                        HStack(spacing: 6) {
                            MembershipGridCell(
                                color: .green,
                                count: model.stats.freeCount,
                                iconName: "dollarsign.circle",
                                title: "Free"
                            ) {
                                model.detailTapped(detailType: .freeUsers)
                            }
                            
                            MembershipGridCell(
                                color: .blue,
                                count: model.stats.premiumCount,
                                iconName: "crown.fill",
                                title: "Premium"
                            ) {
                                model.detailTapped(detailType: .premiumUsers)
                            }
                            
                            MembershipGridCell(
                                color: .purple,
                                count: model.stats.enterpriseCount,
                                iconName: "building.2.fill",
                                title: "Enterprise"
                            ) {
                                model.detailTapped(detailType: .enterpriseUsers)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .padding([.leading, .trailing], -20)
            }
            Section {
                ForEach(model.rows, id: \.user.id) { row in
                    UserRow(user: row.user)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                model.deleteButtonTapped(user: row.user)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button {
                                model.editButtonTapped(user: row.user)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            .disabled(row.user.name.isEmpty)
                        }
                }
            } header: {
                HStack {
                    Text(model.detailType.navigationTitle)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)

                    Spacer()


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
        .sheet(item: $model.userForm) { (user: User.Draft) in
            NavigationStack {
                UserForm(user:user )

                    .navigationTitle("New User")
            }
        }
    }


}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
        NavigationStack {
            UserView(model: UserModel(detailType: .all))
        }
    }
}
