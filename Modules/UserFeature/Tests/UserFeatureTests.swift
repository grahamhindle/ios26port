import ComposableArchitecture
import Dependencies
import DependenciesTestSupport
import GRDB
import SharedModels
import SharingGRDB
import Testing
@testable import UserFeature

@MainActor
struct UserFeatureTests {
    
    // MARK: - UserFeature Tests
    
    @Test func initialState() async throws {
        prepareDependencies {
            $0.context = .test
            do {
                $0.defaultDatabase = try appDatabase()
            } catch {
                fatalError("Database failed to initialize: \(error)")
            }
        }
        
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        }
        
        #expect(store.state.detailType == .all)
        #expect(store.state.userForm == nil)
        #expect(store.state.filteredUserRecords.isEmpty)
    }
    
    @Test func addButtonTapped() async throws {
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        }
        
        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(draft: User.Draft())
        }
    }
    
    @Test func editButtonTapped() async throws {
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        } withDependencies: {
            $0.defaultDatabase = .testValue
        }
        
        let user = User(
            id: 1,
            name: "Test User",
            email: "test@example.com",
            isAuthenticated: false,
            membershipStatus: .free
        )
        
        await store.send(.editButtonTapped(user: user)) {
            $0.userForm = UserFormFeature.State(draft: User.Draft(user))
        }
    }
    
    @Test func detailButtonTapped() async throws {
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        }
        
        await store.send(.detailButtonTapped(detailType: .authenticated)) {
            $0.detailType = .authenticated
        }
        
        await store.send(.detailButtonTapped(detailType: .premiumUsers)) {
            $0.detailType = .premiumUsers
        }
    }
    
    @Test func userFormDelegateDidFinish() async throws {
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        }
        
        // First present the form
        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(draft: User.Draft())
        }
        
        // Then simulate delegate finishing
        await store.send(.userForm(.presented(.delegate(.didFinish)))) {
            $0.userForm = nil
        }
    }
    
    @Test func userFormDelegateDidCancel() async throws {
        let store = TestStore(initialState: UserFeature.State()) {
            UserFeature()
        }
        
        // First present the form
        await store.send(.addButtonTapped) {
            $0.userForm = UserFormFeature.State(draft: User.Draft())
        }
        
        // Then simulate delegate canceling
        await store.send(.userForm(.presented(.delegate(.didCancel)))) {
            $0.userForm = nil
        }
    }
    
    @Test func detailTypeNavigationTitle() async throws {
        #expect(UserFeature.DetailType.all.navigationTitle == "All Users")
        #expect(UserFeature.DetailType.authenticated.navigationTitle == "Authenticated Users")
        #expect(UserFeature.DetailType.guests.navigationTitle == "Guest Users")
        #expect(UserFeature.DetailType.todayUsers.navigationTitle == "Today's Users")
        #expect(UserFeature.DetailType.freeUsers.navigationTitle == "Free Users")
        #expect(UserFeature.DetailType.premiumUsers.navigationTitle == "Premium Users")
        #expect(UserFeature.DetailType.enterpriseUsers.navigationTitle == "Enterprise Users")
        
        let user = User(
            id: 1,
            name: "Test User",
            email: "test@example.com",
            isAuthenticated: false,
            membershipStatus: .free
        )
        #expect(UserFeature.DetailType.users(user).navigationTitle == "Test User")
    }
    
    // MARK: - UserFormFeature Tests
    
    @Test func userFormInitialState() async throws {
        let draft = User.Draft(
            name: "Test User",
            email: "test@example.com",
            dateOfBirth: Date()
        )
        
        let store = TestStore(initialState: UserFormFeature.State(draft: draft)) {
            UserFormFeature()
        }
        
        #expect(store.state.draft.name == "Test User")
        #expect(store.state.draft.email == "test@example.com")
        #expect(store.state.enterBirthday == true) // Because dateOfBirth is set
    }
    
    @Test func userFormInitialStateWithoutBirthday() async throws {
        let draft = User.Draft(
            name: "Test User",
            email: "test@example.com"
        )
        
        let store = TestStore(initialState: UserFormFeature.State(draft: draft)) {
            UserFormFeature()
        }
        
        #expect(store.state.enterBirthday == false) // Because dateOfBirth is nil
    }
    
    @Test func enterBirthdayToggled() async throws {
        let store = TestStore(initialState: UserFormFeature.State(draft: User.Draft())) {
            UserFormFeature()
        }
        
        #expect(store.state.enterBirthday == false)
        #expect(store.state.draft.dateOfBirth == nil)
        
        await store.send(.enterBirthdayToggled(true)) {
            $0.enterBirthday = true
            $0.draft.dateOfBirth = Date()
        }
        
        await store.send(.enterBirthdayToggled(false)) {
            $0.enterBirthday = false
            $0.draft.dateOfBirth = nil
        }
    }
    
    @Test func cancelTapped() async throws {
        let store = TestStore(initialState: UserFormFeature.State(draft: User.Draft())) {
            UserFormFeature()
        }
        
        await store.send(.cancelTapped)
        await store.receive(.delegate(.didCancel))
    }
    
    @Test func authenticationButtonTitle() async throws {
        var draft = User.Draft()
        draft.isAuthenticated = false
        let state = UserFormFeature.State(draft: draft)
        #expect(state.authenticationButtonTitle == "Sign Up")
        
        draft.isAuthenticated = true
        draft.lastSignedInDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let recentState = UserFormFeature.State(draft: draft)
        #expect(recentState.authenticationButtonTitle == "Sign Out")
        
        draft.lastSignedInDate = Date().addingTimeInterval(-86400 * 2) // 2 days ago
        let oldState = UserFormFeature.State(draft: draft)
        #expect(oldState.authenticationButtonTitle == "Sign In")
    }
    
    @Test func isRecentlySignedIn() async throws {
        var draft = User.Draft()
        
        // No sign in date
        draft.lastSignedInDate = nil
        let noDateState = UserFormFeature.State(draft: draft)
        #expect(noDateState.isRecentlySignedIn == false)
        
        // Recent sign in (1 hour ago)
        draft.lastSignedInDate = Date().addingTimeInterval(-3600)
        let recentState = UserFormFeature.State(draft: draft)
        #expect(recentState.isRecentlySignedIn == true)
        
        // Old sign in (2 days ago)
        draft.lastSignedInDate = Date().addingTimeInterval(-86400 * 2)
        let oldState = UserFormFeature.State(draft: draft)
        #expect(oldState.isRecentlySignedIn == false)
    }
}