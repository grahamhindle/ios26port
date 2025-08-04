import Charts
import ComposableArchitecture
import SharedModels
import SharedResources
import SharingGRDB
import UIComponents
import SwiftUI

// import UIComponents

public struct AvatarView: View {
    let store: StoreOf<AvatarFeature>

    public init(store: StoreOf<AvatarFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            MediumGridCell(
                                color: .green,
                                count: store.state.stats.allCount,
                                iconName: "person.fill",
                                title: "All"
                            ) {
                                store.send(.detailButtonTapped(detailType: .all))
                            }

                            MediumGridCell(
                                color: .blue,
                                count: store.state.stats.publicCount,
                                iconName: "person.fill",
                                title: "Public"
                            ) {
                                store.send(.detailButtonTapped(detailType: .publicAvatars))
                            }

                            MediumGridCell(
                                color: .purple,
                                count: store.state.stats.privateCount,
                                iconName: "person.fill",
                                title: "Private"
                            ) {
                                store.send(.detailButtonTapped(detailType: .privateAvatars))
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                // .padding([.leading, .trailing], -20) // Top-level stats
            } header: {
                Text("Avatar Status")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
            Section {
                ForEach(store.state.filteredAvatarRecords, id: \.avatar.id) { record in
                    AvatarRow(avatar: record.avatar)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.send(.deleteButtonTapped(avatar: record.avatar))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button {
                                store.send(.editButtonTapped(avatar: record.avatar))
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            .disabled(record.avatar.name.isEmpty)
                        }
                }

            } header: {
                Text("My Avatars")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .searchable(text: .constant(""))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Avatar")
                        }
                        .bold()
                        .font(.title3)
                    }
                }
            }
        }
        .sheet(
            store: store.scope(state: \.$avatarForm, action: \.avatarForm)
        ) { avatarFormStore in
            NavigationStack {
                AvatarForm(store: avatarFormStore)
            }
        }
//        .sheet(item: $store.state.avatarForm) { avatar in
//            NavigationStack {
//                AvatarForm(avatar: avatar)
//                    .navigationTitle("Avatar")
//            }
//        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable redundant_discardable_let
        // Set up dependencies BEFORE creating Store/State
        let _ = prepareDependencies {
            // swiftlint:disable force_try
            $0.defaultDatabase = try! withDependencies {
                $0.context = .preview
            } operation: {
                try appDatabase()
            }
            $0.context = .preview
            // swiftlint:enable force_try
        }
        
        // Now create Store with properly initialized dependencies
        let store = Store(initialState: AvatarFeature.State()) {
            AvatarFeature()
        }
        
        NavigationStack {
            AvatarView(store: store)
        }
        // swiftlint:enable redundant_discardable_let
    }
}
