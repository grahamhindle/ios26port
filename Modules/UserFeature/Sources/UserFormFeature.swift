import AuthFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import SharingGRDB

@Reducer
public struct UserFormFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {
        public var draft: User.Draft
        public var username = ""
        public var enterBirthday = false
        public var showingStatusInfo = false
        public var auth = AuthFeature.State()
        public var showingSuccessMessage = false

        public init(draft: User.Draft) {
            self.draft = draft
            self.username = draft.name // Initialize with existing name as username for now
            enterBirthday = draft.dateOfBirth != nil
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case enterBirthdayToggled(Bool)
        case statusInfoTapped
        case authenticationButtonTapped
        case saveTapped
        case cancelTapped
        case showSuccessMessage
        case hideSuccessMessage
        case auth(AuthFeature.Action)
        case delegate(Delegate)
        // swiftlint:disable nesting
        public enum Delegate: Equatable, Sendable {
            case didFinish
            case didFinishWithUpdatedUser(User)
            case didCancel
            case didSignOut
        }
    }
    // swiftlint:enable nesting

    @Dependency(\.defaultDatabase) var database

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }

        Reduce { state, action in
            switch action {
            case let .enterBirthdayToggled(isOn):
                state.enterBirthday = isOn
                if isOn, state.draft.dateOfBirth == nil {
                    state.draft.dateOfBirth = Date()
                } else if !isOn {
                    state.draft.dateOfBirth = nil
                }
                return .none

            case .statusInfoTapped:
                state.showingStatusInfo.toggle()
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
                // Check for sign out first (empty authId means signed out)
                if authId.isEmpty {
                    print("🔍 UserFormFeature: Sign out detected, sending didSignOut delegate")
                    return .send(.delegate(.didSignOut))
                }

                // Update the draft with authentication information
                state.draft.authId = authId
                state.draft.isAuthenticated = true
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
                state.showingSuccessMessage = false
                return .run { [draft = state.draft, database] send in
                    do {
                        print("🔍 Starting save operation for user: \(draft.name)")
                        print("🔥 UserFormFeature: Using database - path: \(database.path)")

                        // If we got an in-memory database, try to get the proper one
                        let workingDatabase = database.path == ":memory:" ? (try? appDatabase()) ?? database : database
                        print("🔥 UserFormFeature: Using working database - path: \(workingDatabase.path)")

                        // Save the user and get the updated user back
                        let updatedUser = try await workingDatabase.write { database in
                            try User.upsert { draft }.returning(\.self).fetchOne(database)!
                        }
                        print("🔍 Save operation completed successfully for user: \(updatedUser.name)")
                        await send(.showSuccessMessage)
                        await send(.delegate(.didFinishWithUpdatedUser(updatedUser)))
                    } catch {
                        print("🔍 Save operation failed: \(error)")
                        // For now, still send didFinish even on error
                        await send(.delegate(.didFinish))
                    }
                }

            case .showSuccessMessage:
                state.showingSuccessMessage = true
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.hideSuccessMessage)
                }

            case .hideSuccessMessage:
                state.showingSuccessMessage = false
                return .none

            case .delegate:
                return .none

            case .binding:
                return .none

            case .auth(.signOut):
                // Sign out initiated
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
            "Sign Up"
        } else if isRecentlySignedIn {
            "Sign Out"
        } else {
            "Sign In"
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
