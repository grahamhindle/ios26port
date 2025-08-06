import ComposableArchitecture
import Foundation
import SharedModels
import SharingGRDB
import AuthFeature

@Reducer
public struct UserFormFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        public var draft: User.Draft
        public var enterBirthday = false
        public var auth = AuthFeature.State()

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
        case auth(AuthFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case didFinish
            case didCancel
        }
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.auth, action: /Action.auth) {
            AuthFeature()
        }
        
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
                // Determine which authentication action to take based on current state
                if !state.draft.isAuthenticated {
                    return .send(.auth(.signUp))
                } else if state.isRecentlySignedIn {
                    return .send(.auth(.signOut))
                } else {
                    return .send(.auth(.signIn))
                }

            case let .auth(.authenticationSucceeded(authId, provider, email)):
                // Update the draft with authentication information
                state.draft.authId = authId
                state.draft.isAuthenticated = !authId.isEmpty
                state.draft.providerID = provider
                state.draft.email = email
                state.draft.lastSignedInDate = Date()
                return .none

            case let .auth(.authenticationFailed(error)):
                // Handle authentication error - could show an alert or update UI
                print("Authentication failed: \(error)")
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
            case .auth:
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
    
    var isAuthenticating: Bool {
        auth.isLoading
    }
    
    var authenticationError: String? {
        auth.errorMessage
    }
}