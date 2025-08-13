import ComposableArchitecture
import DatabaseModule
import Foundation
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
                            GridCell(
                                size: .small,
                                color: .green,
                                count: store.stats.allCount,
                                iconName: "person.fill",
                                title: "All"
                            ) {
                                store.send(.detailButtonTapped(detailType: .all))
                            }

                            GridCell(
                                size: .small,
                                color: .blue,
                                count: store.stats.publicCount,
                                iconName: "person.fill",
                                title: "Public"
                            ) {
                                store.send(.detailButtonTapped(detailType: .publicAvatars))
                            }

                            GridCell(
                                size: .small,
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
                    .foregroundStyle(SharedColors.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 0)
            }
            Section {
                ZStack {
                    CarouselView(items: store.popularAvatars) { avatar in
                        HeroCellView(
                            title: avatar.name,
                            subtitle: avatar.promptCharacterMood?.displayName,
                            imageName: avatar.profileImageURL
                        )

                        .anyButton { store.send(.editButtonTapped(avatar: avatar)) }
                    }
                }
                .padding()
            }
            header: {
                Text("Popular")
                    .font(.headline)
                    .foregroundStyle(SharedColors.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            }
            .removeListRowFormatting()

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
                    .foregroundStyle(SharedColors.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
        }
        .searchable(text: .constant(""))
        .listStyle(.plain)
        .listSectionSpacing(4)
        .contentMargins(.top, -8, for: .scrollContent)
        .onAppear {
            store.send(.onAppear)
        }

        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    HStack {
                        Image(systemName: "person.fill.badge.plus")
                        Text("New Avatar")
                    }
                    .foregroundStyle(SharedColors.accent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.promptBuilderButtonTapped)
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("New Avatar")
                    }
                    .foregroundStyle(SharedColors.accent)
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

#Preview {
    // swiftlint:disable:next redundant_discardable_let
    let _ = prepareDependencies {
        do {
            $0.defaultDatabase = try withDependencies {
                $0.context = .preview
            } operation: {
                try appDatabase()
            }
            $0.context = .preview
        } catch {
            print("Failed to prepare database for preview: \(error)")
        }
    }
    // Now create Store with properly initialized dependencies
    let store = Store(initialState: AvatarFeature.State()) {
        AvatarFeature()
    }

    NavigationStack {
        AvatarView(store: store)
    }
}
