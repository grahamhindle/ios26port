import ComposableArchitecture
import Foundation
import DatabaseModule
import SharedResources
import SharingGRDB
import StructuredQueriesGRDB
import SwiftUI

@Reducer
public struct UserFeature: Sendable {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        // stats for users by type
        @ObservationStateIgnored
        @FetchOne(User.select {
            UserStats.Columns(
                allCount: $0.count(),
                authenticated: $0.count(filter: $0.isAuthenticated),
                guests: $0.count(filter: !$0.isAuthenticated),
                todayCount: $0.count(filter: $0.isToday),
                freeCount: $0.count(filter: $0.isFree),
                premiumCount: $0.count(filter: $0.isPremium),
                enterpriseCount: $0.count(filter: $0.isEnterprise)
            )
        }) public var stats = UserStats()

        public var detailType: DetailType = .all

        // fetch list of users - will be filtered by current detailType
        @ObservationStateIgnored
        @FetchAll(User.order(by: \.name).select { UserRecords.Columns(user: $0) })
        var userRecords: [UserRecords] = []

        // computed property to filter users based on detailType
        var filteredUserRecords: [UserRecords] {
            switch detailType {
            case .all, .users:
                return userRecords
            case .authenticated:
                return userRecords.filter { $0.user.isAuthenticated }
            case .guests:
                return userRecords.filter { !$0.user.isAuthenticated }
            case .todayUsers:
                return userRecords.filter { user in
                    guard let lastSignedIn = user.user.lastSignedInDate else { return false }
                    return Calendar.current.isDateInToday(lastSignedIn)
                }
            case .freeUsers:
                return userRecords.filter { $0.user.membershipStatus == .free }
            case .premiumUsers:
                return userRecords.filter { $0.user.membershipStatus == .premium }
            case .enterpriseUsers:
                return userRecords.filter { $0.user.membershipStatus == .enterprise }
            }
        }

        @Presents var userForm: UserFormFeature.State?
        public init() {}

        @Selection
        public struct UserStats: Equatable, Sendable {
            public var allCount = 0
            public var authenticated = 0
            public var guests = 0
            public var todayCount = 0
            public var freeCount = 0
            public var premiumCount = 0
            public var enterpriseCount = 0
        }

        @Selection
        public struct UserRecords: Equatable, Sendable {
            public let user: User
        }
    }

    public enum DetailType: Equatable, Sendable {
        case all
        case authenticated
        case guests
        case todayUsers
        case freeUsers
        case premiumUsers
        case enterpriseUsers
        case users(User)

        public var navigationTitle: String {
            switch self {
            case .users(let user):
                return user.name
            case .all:
                return "All Users"
            case .authenticated:
                return "Authenticated Users"
            case .guests:
                return "Guest Users"
            case .todayUsers:
                return "Today's Users"
            case .freeUsers:
                return "Free Users"
            case .premiumUsers:
                return "Premium Users"
            case .enterpriseUsers:
                return "Enterprise Users"
            }
        }

        public var color: Color {
            switch self {
            case .users(let user):
                return Color(hex: user.themeColorHex)
            case .all:
                return .black
            case .authenticated:
                return .green
            case .guests:
                return .brown
            case .todayUsers:
                return .blue
            case .freeUsers:
                return .yellow.opacity(0.25)
            case .premiumUsers:
                return .yellow.opacity(0.50)
            case .enterpriseUsers:
                return .yellow.opacity(0.95)
            }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addButtonTapped
        case editButtonTapped(user: User)
        case deleteButtonTapped(user: User)
        case detailButtonTapped(detailType: DetailType)
        case onAppear

        case userForm(PresentationAction<UserFormFeature.Action>)
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.userForm = UserFormFeature.State(
                    draft: User.Draft()
                )
                return .none
            case .binding:
                return .none
            case let .editButtonTapped(user):
                state.userForm = UserFormFeature.State(draft: User.Draft(user))
                return .none

            case let .deleteButtonTapped(user):
                return .run { _ in
                    withErrorReporting {
                        try database.write { database in
                            try User
                                .delete(user)
                                .execute(database)
                        }
                    }
                }

            case let .detailButtonTapped(detailType):
                state.detailType = detailType
                return .none

            case .onAppear:
                return .none

            case .userForm(.presented(.saveTapped)):
                return .none

            case .userForm(.presented(.delegate(.didFinish))):
                state.userForm = nil
                return .none

            case .userForm(.presented(.delegate(.didCancel))):
                state.userForm = nil
                return .none

            case .userForm:
                return .none
            }
        }
        .ifLet(\.$userForm, action: \.userForm) {
            UserFormFeature()
        }
    }
}

public struct UserStoreFactory: DependencyKey {
    public static let liveValue: @MainActor () -> StoreOf<UserFeature> = {
        Store(initialState: UserFeature.State()) {
            UserFeature()
        }
    }

    public static let testValue: @MainActor () -> StoreOf<UserFeature> = liveValue
    public static let previewValue = testValue
}

public extension DependencyValues {
    var userStoreFactory: @MainActor () -> StoreOf<UserFeature> {
        get { self[UserStoreFactory.self] }
        set { self[UserStoreFactory.self] = newValue }
    }
}
