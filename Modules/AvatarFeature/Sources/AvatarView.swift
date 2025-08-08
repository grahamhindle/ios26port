import ComposableArchitecture
import Foundation
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI
import UIComponents

public struct AvatarView: View {
    @Bindable var store: StoreOf<AvatarFeature>
    
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
                                count: store.stats.allCount,
                                iconName: "person.fill",
                                title: "All"
                            ) {
                                store.send(.detailButtonTapped(detailType: .all))
                            }

                            MediumGridCell(
                                color: .blue,
                                count: store.stats.publicCount,
                                iconName: "person.fill",
                                title: "Public"
                            ) {
                                store.send(.detailButtonTapped(detailType: .publicAvatars))
                            }

                            MediumGridCell(
                                color: .purple,
                                count: store.stats.privateCount,
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
            } header: {
                Text("Avatar Status")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
            
            Section {
                // Prompt Builder Button
                Button(action: { store.send(.promptBuilderButtonTapped) }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.blue)
                        Text("Prompt Builder")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            } header: {
                Text("Tools")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
            
            Section {
                ForEach(store.filteredAvatarRecords, id: \.avatar.id) { record in
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
        .sheet(
            store: store.scope(state: \.$promptBuilder, action: \.promptBuilder)
        ) { promptBuilderStore in
            PromptBuilderView(store: promptBuilderStore)
        }
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
