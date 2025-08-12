import Charts
import ComposableArchitecture
import DatabaseModule
import Foundation
import SharedResources
import SharingGRDB
import SwiftUI
import UIComponents

public struct UserView: View {
    let store: StoreOf<UserFeature>

    public init(store: StoreOf<UserFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    // Users Group - 2 rows of 2 cells each
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            GridCell(
                                size: .large,
                                color: .green,
                                count: store.state.stats.allCount,
                                iconName: "person.3.fill",
                                title: "All Users"
                            ) {
                                store.send(.detailButtonTapped(detailType: .all))
                            }

                            GridCell(
                                size: .large,
                                color: .blue,
                                count: store.state.stats.todayCount,
                                iconName: "calendar.circle.fill",
                                title: "Today"
                            ) {
                                store.send(.detailButtonTapped(detailType: .todayUsers))
                            }
                        }

                        HStack(spacing: 8) {
                            GridCell(
                                size: .large,
                                color: .orange,
                                count: store.state.stats.authenticated,
                                iconName: "checkmark.shield.fill",
                                title: "Authenticated"
                            ) {
                                store.send(.detailButtonTapped(detailType: .authenticated))
                            }

                            GridCell(
                                size: .large,
                                color: .gray,
                                count: store.state.stats.guests,
                                iconName: "person.crop.circle.dashed",
                                title: "Guests"
                            ) {
                                store.send(.detailButtonTapped(detailType: .guests))
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
                            GridCell(
                                size: .medium,
                                color: .green,
                                count: store.state.stats.freeCount,
                                iconName: "dollarsign.circle",
                                title: "Free"
                            ) {
                                store.send(.detailButtonTapped(detailType: .freeUsers))
                            }

                            GridCell(
                                size: .medium,
                                color: .blue,
                                count: store.state.stats.premiumCount,
                                iconName: "crown.fill",
                                title: "Premium"
                            ) {
                                store.send(.detailButtonTapped(detailType: .premiumUsers))
                            }

                            GridCell(
                                size: .medium,
                                color: .purple,
                                count: store.state.stats.enterpriseCount,
                                iconName: "building.2.fill",
                                title: "Enterprise"
                            ) {
                                store.send(.detailButtonTapped(detailType: .enterpriseUsers))
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .padding([.leading, .trailing], -20)
            }
            Section {
                ForEach(store.state.filteredUserRecords, id: \.user.id) { record in
                    UserRow(user: record.user)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.send(.deleteButtonTapped(user: record.user))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button {
                                store.send(.editButtonTapped(user: record.user))
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            .disabled(record.user.name.isEmpty)
                        }
                }
            } header: {
                HStack {
                    Text(store.state.detailType.navigationTitle)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)

                    Spacer()
                }
            }
        }
        .searchable(text: .constant(""))
        .onAppear {
            store.send(.onAppear)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        store.send(.addButtonTapped)
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
        .sheet(
            store: store.scope(state: \.$userForm, action: \.userForm)
        ) { userFormStore in
            NavigationStack {
                UserFormView(store: userFormStore)
                    .navigationTitle("User")
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable redundant_discardable_let
        let _ = prepareDependencies {
            // swiftlint:disable force_try
            $0.defaultDatabase = try! appDatabase()
            // swiftlint:enable force_try
        }
        NavigationStack {
            UserView(store: Store(initialState: UserFeature.State()) {
                UserFeature()
            })
        }
        // swiftlint:enable redundant_discardable_let
    }
}
