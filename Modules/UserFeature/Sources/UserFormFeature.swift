import ComposableArchitecture
import Foundation
import SharedModels
import SharingGRDB

@Reducer
public struct UserFormFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        public var draft: User.Draft
        public var enterBirthday = false

        public init(draft: User.Draft) {
            self.draft = draft
            self.enterBirthday = draft.dateOfBirth != nil
        }
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case enterBirthdayToggled(Bool)
        case authenticationButtonTapped
        case saveTapped
        case cancelTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case didFinish
            case didCancel
        }
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .enterBirthdayToggled(isOn):
                state.enterBirthday = isOn
                if isOn && state.draft.dateOfBirth == nil {
                    state.draft.dateOfBirth = Date()
                } else if !isOn {
                    state.draft.dateOfBirth = nil
                }
                return .none

            case .authenticationButtonTapped:
                // TODO: Handle authentication - for now just a placeholder
                return .none

            case .cancelTapped:
                return .send(.delegate(.didCancel))

            case .saveTapped:
                return .run { [draft = state.draft, database] send in
                    withErrorReporting {
                        try database.write { db in
                            try User.upsert { draft }.execute(db)
                        }
                    }
                    await send(.delegate(.didFinish))
                }

            case .delegate:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

// Helper computed properties for the view
public extension UserFormFeature.State {
    var authenticationButtonTitle: String {
        if !draft.isAuthenticated {
            return "Sign Up"
        } else if isRecentlySignedIn {
            return "Sign Out"
        } else {
            return "Sign In"
        }
    }
    
    var isRecentlySignedIn: Bool {
        guard let lastSignedIn = draft.lastSignedInDate else { return false }
        let hoursSinceSignIn = Date().timeIntervalSince(lastSignedIn) / 3600
        return hoursSinceSignIn < 24
    }
}