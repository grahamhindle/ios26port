import ComposableArchitecture
import DatabaseModule
import Foundation
import SharingGRDB
import StructuredQueriesGRDB
import SwiftUI

@Reducer
public struct AvatarFeature: Sendable {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        @FetchOne(Avatar.select {
            Stats.Columns(
                allCount: $0.count(),
                publicCount: $0.count(filter: $0.isPublic),
                privateCount: $0.count(filter: !$0.isPublic)
            )
        }) public var stats = Stats()

        @ObservationStateIgnored
        @FetchAll(
            Avatar
                // .where { $0.id.eq() }
                .order(by: \.dateCreated)
                .limit(10)
                .select { PopularAvatar.Columns(avatar: $0) }
        )
        var popularAvatarRecords: [PopularAvatar] = []

        var popularAvatars: [Avatar] {
            let allPopular = popularAvatarRecords.map(\.avatar)
            // Filter popular avatars based on current detailType
            return allPopular.filter { avatar in
                switch detailType {
                case .all:
                    true
                case .publicAvatars:
                    avatar.isPublic
                case .privateAvatars:
                    !avatar.isPublic
                }
            }
        }

        public var detailType: DetailType = .all

        // fetch list of avatars - will be filtered by current detailType
        @ObservationStateIgnored
        @FetchAll(Avatar.order(by: \.promptCategory).select { AvatarRecords.Columns(avatar: $0) })
        var avatarRecords: [AvatarRecords] = []

        // computed property to filter avatars based on detailType
        var filteredAvatarRecords: [AvatarRecords] {
            avatarRecords.filter { record in
                switch detailType {
                case .all:
                    true
                case .publicAvatars:
                    record.avatar.isPublic
                case .privateAvatars:
                    !record.avatar.isPublic
                }
            }
        }

        @Presents var avatarForm: AvatarFormFeature.State?
        @Presents var promptBuilder: PromptBuilderFeature.State?

        var user: User?

        public init() {}
        public init(user: User) {
            self.user = user
        }

        @Selection
        public struct Stats: Equatable, Sendable {
            public var allCount = 0
            public var publicCount = 0
            public var privateCount = 0
        }
    }

    public enum DetailType: Equatable, Sendable {
        case all
        case publicAvatars
        case privateAvatars

        public var title: String {
            switch self {
            case .all: "All"
            case .publicAvatars: "Public"
            case .privateAvatars: "Private"
            }
        }

        public var color: Color {
            switch self {
            case .all: .green
            case .publicAvatars: .blue
            case .privateAvatars: .red
            }
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case addButtonTapped
        case editButtonTapped(avatar: Avatar)
        case deleteButtonTapped(avatar: Avatar)
        case detailButtonTapped(detailType: DetailType)
        case promptBuilderButtonTapped
        case onAppear
        case avatarForm(PresentationAction<AvatarFormFeature.Action>)
        case promptBuilder(PresentationAction<PromptBuilderFeature.Action>)
        case updateQuery
    }

    @Dependency(\.defaultDatabase) var database
    @Dependency(\.currentUserId) var currentUserId

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.avatarForm = AvatarFormFeature.State(
                    draft: Avatar.Draft(
                        name: "",
                        userId: currentUserId(),
                        isPublic: true
                    )
                )
                return .none

            case .binding:
                return .none

            case let .editButtonTapped(avatar):
                state.avatarForm = AvatarFormFeature.State(draft: Avatar.Draft(avatar))
                return .none

            case let .deleteButtonTapped(avatar):
                return .run { _ in
                    withErrorReporting {
                        try database.write { database in
                            try Avatar
                                .delete(avatar)
                                .execute(database)
                        }
                    }
                }

            case let .detailButtonTapped(detailType):
                withAnimation(.easeInOut(duration: 0.3)) {
                    state.detailType = detailType
                }
                return .none

            case .promptBuilderButtonTapped:
                state.promptBuilder = PromptBuilderFeature.State()
                return .none

            case .onAppear:
                return .send(.updateQuery)

            case .avatarForm(.presented(.saveTapped)):
                return .none

            case .avatarForm(.presented(.delegate(.didFinish))):
                state.avatarForm = nil
                return .none

            case .avatarForm(.presented(.delegate(.didCancel))):
                state.avatarForm = nil
                return .none

            case .avatarForm:
                return .none

            case .promptBuilder(.presented(.usePromptTapped)):
                state.promptBuilder = nil
                print("🎯 Generated Prompt:")
                print(state.promptBuilder?.generatedPrompt ?? "No prompt generated")
                // Here you would send the prompt to Claude
                return .none

            case .promptBuilder(.presented(.cancelTapped)):
                state.promptBuilder = nil
                return .none

            case .promptBuilder:
                return .none

            case .updateQuery:
                return .run { [stats = state.$stats, avatarRecords = state.$avatarRecords, popularAvatarRecords = state.$popularAvatarRecords] _ in
                    await withErrorReporting {
                        try await stats.load()
                        try await avatarRecords.load()
                        try await popularAvatarRecords.load()
                    }
                }
            }

        }
        .ifLet(\.$avatarForm, action: \.avatarForm) {
            AvatarFormFeature()
        }
        .ifLet(\.$promptBuilder, action: \.promptBuilder) {
            PromptBuilderFeature()
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

    var currentUserId: @Sendable () -> User.ID {
        get { self[CurrentUserIdKey.self] }
        set { self[CurrentUserIdKey.self] = newValue }
    }
}

public struct CurrentUserIdKey: DependencyKey {
    public static let liveValue: @Sendable () -> User.ID = { 1 } // Default for now
    public static let testValue: @Sendable () -> User.ID = { 1 }
    public static let previewValue = testValue
}
