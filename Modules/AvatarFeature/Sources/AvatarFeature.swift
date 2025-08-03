import ComposableArchitecture
import Foundation
import SharedModels
import SharingGRDB
import StructuredQueriesGRDB
import SwiftUI

@Reducer
public struct AvatarFeature: Sendable {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        @FetchAll(Avatar.order(by: \.name)) public var avatars: [Avatar] = []
        // stats for all, public, private
        @ObservationStateIgnored
        @FetchOne(Avatar.select {
            Stats.Columns(
                allCount: $0.count(),
                publicCount: $0.count(filter: $0.isPublic),
                privateCount: $0.count(filter: !$0.isPublic)
            )
        }) public var stats = Stats()

        @Selection
        public struct Stats: Equatable, Sendable {
            public var allCount = 0
            public var publicCount = 0
            public var privateCount = 0
        }

        // fetch list of avatars based on detailType
        @ObservationStateIgnored
        @FetchAll var avatarRecords: [AvatarRecords] = []

        public func updateQuery() async {
            let query = Avatar
                .where {
                    switch detailType {
                    case .all:
                        true
                    case .publicAvatars:
                        $0.isPublic
                    case .privateAvatars:
                        !$0.isPublic
                    }
                }
                .select { avatar in
                    AvatarRecords.Columns(avatar: avatar)
                }

            await withErrorReporting {
                try await $avatarRecords.load(query, animation: .default)
            }
        }

        public var detailType: DetailType = .all
        @Presents var avatarForm: AvatarFormFeature.State?
        public init() {}

        @Selection
        struct AvatarRecords: Equatable, Sendable {
            let avatar: Avatar
        }

        // editing details
    }

    public enum DetailType: Equatable, Sendable {
        case all
        case publicAvatars
        case privateAvatars

        public var title: String {
            switch self {
            case .all: return "All"
            case .publicAvatars: return "Public"
            case .privateAvatars: return "Private"
            }
        }

        public var color: Color {
            switch self {
            case .all: return .green
            case .publicAvatars: return .blue
            case .privateAvatars: return .red
            }
        }
    }

    public enum Action: BindableAction {
           case binding(BindingAction<State>)
        case addButtonTapped
        case editButtonTapped(avatar: Avatar)
        case deleteButtonTapped(avatar: Avatar)
        case detailButtonTapped(detailType: DetailType)
        case onAppear
        case avatarForm(PresentationAction<AvatarFormFeature.Action>)
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.avatarForm = AvatarFormFeature.State(
                    draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
                )
                return .none
            case .binding:
                return .none
            case let .editButtonTapped(avatar):
                state.avatarForm = AvatarFormFeature.State(draft: Avatar.Draft(avatar))
                return .none

            case let .deleteButtonTapped(avatar):
                return .run { [state] _ in
                    withErrorReporting {
                        try  database.write { db in
                            try  Avatar
                                .delete(avatar)
                                .execute(db)
                        }

                    }
                    await state.updateQuery()
                }

            case let .detailButtonTapped(detailType):
                state.detailType = detailType
                return .run { [state] _ in
                    await state.updateQuery()
                }

            case .onAppear:
                return .run { [state] _ in
                    await state.updateQuery()
                }

            case .avatarForm(.presented(.saveTapped)):
                return .run { [state] _ in
                    await state.updateQuery()
                }

            case .avatarForm(.presented(.delegate(.didFinish))):
                state.avatarForm = nil
                return .run { [state] _ in
                    await state.updateQuery()
                }

            case .avatarForm(.presented(.delegate(.didCancel))):
                state.avatarForm = nil
                return .none

            case .avatarForm:
                return .none
            }
        }
        .ifLet(\.$avatarForm, action: \.avatarForm) {
            AvatarFormFeature()
        }
    }
}

public struct AvatarStoreFactory: DependencyKey {
    public static let liveValue: @MainActor () -> StoreOf<AvatarFeature> = {
        Store(initialState: AvatarFeature.State()) {
            AvatarFeature()
        }
    }

    public static let testValue: @MainActor () -> StoreOf<AvatarFeature> = liveValue
    public static let previewValue = testValue
}

public extension DependencyValues {
    var avatarStoreFactory: @MainActor () -> StoreOf<AvatarFeature> {
        get { self[AvatarStoreFactory.self] }
        set { self[AvatarStoreFactory.self] = newValue }
    }
}
