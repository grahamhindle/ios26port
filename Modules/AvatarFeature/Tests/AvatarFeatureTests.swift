//
//  AvatarFeatureTests.swift
//  AvatarFeatureTests
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

/*
 TCA + SharingGRDB Testing Setup Documentation
 ============================================
 
 This file demonstrates the correct approach for testing TCA features that use 
 SharingGRDB's @FetchAll and @FetchOne property wrappers.
 
 ## Problem Statement
 When testing TCA reducers with @FetchAll/@FetchOne property wrappers, the standard
 @Suite(.dependency(\.defaultDatabase, ...)) approach doesn't work reliably.
 The property wrappers initialize before the TestStore can apply dependencies,
 causing them to fall back to SharingGRDB's default blank in-memory database.
 
 ## Root Cause
 1. @FetchAll property wrappers access \.defaultDatabase during State initialization
 2. @Suite dependency injection happens too late in the initialization process
 3. SharingGRDB's DefaultDatabaseKey.testValue creates blank in-memory database
 4. This triggers "Issue recorded at DefaultDatabase.swift:42:42" warnings
 
 ## Working Solution: prepareDependencies Method
 Use prepareDependencies within individual test methods BEFORE creating any State
 that contains @FetchAll/@FetchOne property wrappers:
 
 ```swift
 @Test func myTest() async throws {
     // 1. Create the database with seeded data
     let database = try withDependencies {
         $0.context = .test
     } operation: {
         try appDatabase() // This runs migrations + seeding
     }
     
     // 2. Set global dependencies BEFORE State creation
     prepareDependencies {
         $0.defaultDatabase = database
         $0.context = .test
     }
     
     // 3. Now @FetchAll will use the seeded database
     let state = AvatarFeature.State() // @FetchAll connects to seeded DB
     let store = await TestStore(initialState: state) {
         AvatarFeature()
     }
     
     // 4. Verify database connectivity
     #expect(await store.state.avatarRecords.count > 0)
 }
 ```
 
 ## Why This Works
 - prepareDependencies sets the global dependency context
 - @FetchAll property wrappers access this context during State initialization
 - Database contains seeded data from appDatabase() migrations
 - No more blank in-memory database fallback
 
 ## Database Setup (appDatabase())
 The database is automatically seeded with test data during migration:
 - 3 Users (including guest user)
 - 3 Avatars (public and private)
 - Chat conversations and messages
 - Tags and badges for testing relationships
 
 ## Failed Approaches Tried
 ❌ @Suite(.dependency(\.defaultDatabase, ...)) - dependency timing issue
 ❌ TestStore withDependencies only - too late for @FetchAll initialization
 ❌ withDependencies around State creation - still timing issues
 
 ## Key Testing Patterns
 - Always call prepareDependencies BEFORE creating State with @FetchAll
 - Verify database seeding with direct SQL queries
 - Test @FetchAll results with #expect assertions
 - Use await when accessing async State properties in tests
 
 This approach provides a reliable foundation for testing TCA features with 
 database dependencies.
 */

import ComposableArchitecture
//import CustomDump
import DependenciesTestSupport
import SharedModels
import SharingGRDB
import SwiftUI
import Testing
@testable import AvatarFeature


struct AvatarFeatureTests {

    // MARK: - AvatarFeature Tests

    @Test func databaseLoads() async throws {
        // Set up database dependency using prepareDependencies
        let database = try withDependencies {
            $0.context = .test
        } operation: {
            try appDatabase()
        }
        
        prepareDependencies {
            $0.defaultDatabase = database
            $0.context = .test
        }
        
        print("🔥 Starting test with suite database: \(database)")
        
        // First, let's verify the database has data directly
        let avatarCount = try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM avatar") ?? 0
        }
        print("🔥 Direct query shows \(avatarCount) avatars in database")
        
        // Create the state within the dependency context so @FetchAll captures the right database
        let initialState = withDependencies {
            $0.defaultDatabase = database
            $0.context = .test
            $0.currentUserId = { 1 }
        } operation: {
            AvatarFeature.State()
        }
        
        let store = await TestStore(initialState: initialState) {
            AvatarFeature()
        } withDependencies: { @Sendable in
            $0.defaultDatabase = database 
            $0.context = .test
            $0.currentUserId = { 1 }
        }
        
        // Now test if @FetchAll works
        print("🔥 Store state has \(await store.state.avatarRecords.count) avatar records")
        
        // Try to load the @FetchAll manually
        try await store.state.$avatarRecords.load()
        print("🔥 After manual load: \(await store.state.avatarRecords.count) avatar records")
        
        // Load stats
        try await store.state.$stats.load()
        print("🔥 Stats after load: \(await store.state.stats)")
        
        print("🔥 Test completed")
        
        // Add expectations to verify the database is working
        #expect(avatarCount > 0, "Database should contain seeded avatars")
        #expect(await store.state.avatarRecords.count > 0, "State should load avatar records from database")
        #expect(await store.state.stats.allCount > 0, "Stats should show avatar count from database")
    }
}

//    @Test func addButtonTapped() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        }
//        
//        await store.send(.addButtonTapped) {
//            $0.avatarForm = AvatarFormFeature.State(
//                draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
//            )
//        }
//    }
//    
//    @Test func editButtonTapped() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        }
//        
//        let avatar = Avatar(
//            id: 1,
//            name: "Test Avatar",
//            userId: 1,
//            isPublic: true
//        )
//        
//        await store.send(.editButtonTapped(avatar: avatar)) {
//            $0.avatarForm = AvatarFormFeature.State(draft: Avatar.Draft(avatar))
//        }
//    }
//    
//    @Test func detailButtonTapped() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        }
//        
//        await store.send(.detailButtonTapped(detailType: .publicAvatars)) {
//            $0.detailType = .publicAvatars
//        }
//        
//        await store.send(.detailButtonTapped(detailType: .privateAvatars)) {
//            $0.detailType = .privateAvatars
//        }
//        
//        await store.send(.detailButtonTapped(detailType: .all)) {
//            $0.detailType = .all
//        }
//    }
//    
//    @Test func avatarFormDelegateDidFinish() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        }
//        
//        // First present the form
//        await store.send(.addButtonTapped) {
//            $0.avatarForm = AvatarFormFeature.State(
//                draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
//            )
//        }
//        
//        // Then simulate delegate finishing
//        await store.send(\.avatarForm.presented.delegate.didFinish) {
//            $0.avatarForm = nil
//        }
//    }
//    
//    @Test func avatarFormDelegateDidCancel() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        }
//        
//        // First present the form
//        await store.send(.addButtonTapped) {
//            $0.avatarForm = AvatarFormFeature.State(
//                draft: Avatar.Draft(name: "", userId: 1, isPublic: true)
//            )
//        }
//        
//        // Then simulate delegate canceling
//        await store.send(\.avatarForm.presented.delegate.didCancel) {
//            $0.avatarForm = nil
//        }
//    }
//    
//    @Test func detailTypeProperties() async throws {
//        #expect(AvatarFeature.DetailType.all.title == "All")
//        #expect(AvatarFeature.DetailType.publicAvatars.title == "Public")
//        #expect(AvatarFeature.DetailType.privateAvatars.title == "Private")
//        
//        #expect(AvatarFeature.DetailType.all.color == .green)
//        #expect(AvatarFeature.DetailType.publicAvatars.color == .blue)
//        #expect(AvatarFeature.DetailType.privateAvatars.color == .red)
//    }
//}
//
//// MARK: - AvatarFormFeature Tests
//
//@MainActor
//@Suite(.dependency(\.defaultDatabase, try! withDependencies {
//  $0.context = .test
//} operation: {
//  try appDatabase()
//}))
//struct AvatarFormFeatureTests {
//    
//    @Test func avatarFormInitialState() async throws {
//        let draft = Avatar.Draft(
//            name: "Test Avatar",
//            userId: 1,
//            isPublic: true
//        )
//        
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: draft)) {
//            AvatarFormFeature()
//        }
//        
//        #expect(store.state.draft.name == "Test Avatar")
//        #expect(store.state.draft.userId == 1)
//        #expect(store.state.draft.isPublic == true)
//        #expect(store.state.showingImagePicker == false)
//    }
//    
//    @Test func nameChanged() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.nameChanged("New Avatar Name")) {
//            $0.draft.name = "New Avatar Name"
//        }
//    }
//    
//    @Test func subtitleChanged() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.subtitleChanged("Test Subtitle")) {
//            $0.draft.subtitle = "Test Subtitle"
//        }
//        
//        // Test empty subtitle becomes nil
//        await store.send(.subtitleChanged("")) {
//            $0.draft.subtitle = nil
//        }
//    }
//    
//    @Test func isPublicToggled() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.isPublicToggled(true)) {
//            $0.draft.isPublic = true
//        }
//        
//        await store.send(.isPublicToggled(false)) {
//            $0.draft.isPublic = false
//        }
//    }
//    
//    @Test func characterSelectionUpdatesName() async throws {
//        var state = AvatarFormFeature.State(draft: Avatar.Draft())
//        
//        let store = TestStore(initialState: state) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.characterOptionChanged(CharacterOption.man)) {
//            $0.draft.characterOption = CharacterOption.man
//            $0.updateGeneratedName()
//            $0.updateGeneratedSubtitle()
//        }
//        
//        await store.send(.characterActionChanged(CharacterAction.working)) {
//            $0.draft.characterAction = CharacterAction.working
//            $0.updateGeneratedName()
//            $0.updateGeneratedSubtitle()
//        }
//        
//        await store.send(.characterLocationChanged(CharacterLocation.city)) {
//            $0.draft.characterLocation = CharacterLocation.city
//            $0.updateGeneratedName()
//            $0.updateGeneratedSubtitle()
//        }
//        
//        #expect(store.state.draft.name == "Business Professional")
//    }
//    
//    @Test func generateAvatarName() async throws {
//        let state = AvatarFormFeature.State(draft: Avatar.Draft())
//        
//        let businessProfessional = state.generateAvatarName(
//            option: CharacterOption.man,
//            action: CharacterAction.working,
//            location: CharacterLocation.city
//        )
//        #expect(businessProfessional == "Business Professional")
//        
//        let casualWalker = state.generateAvatarName(
//            option: CharacterOption.woman,
//            action: CharacterAction.walking,
//            location: CharacterLocation.park
//        )
//        #expect(casualWalker == "Casual Walker")
//        
//        let spaceExplorer = state.generateAvatarName(
//            option: CharacterOption.alien,
//            action: CharacterAction.relaxing,
//            location: CharacterLocation.space
//        )
//        #expect(spaceExplorer == "Space Explorer")
//        
//        // Test default case
//        let defaultName = state.generateAvatarName(
//            option: CharacterOption.dog,
//            action: CharacterAction.eating,
//            location: CharacterLocation.desert
//        )
//        #expect(defaultName == "eating Dog")
//    }
//    
//    @Test func generateAvatarSubtitle() async throws {
//        let state = AvatarFormFeature.State(draft: Avatar.Draft())
//        
//        let businessSubtitle = state.generateAvatarSubtitle(
//            action: CharacterAction.working,
//            location: CharacterLocation.city
//        )
//        #expect(businessSubtitle == "Ready for meetings")
//        
//        let walkingSubtitle = state.generateAvatarSubtitle(
//            action: CharacterAction.walking,
//            location: CharacterLocation.park
//        )
//        #expect(walkingSubtitle == "Enjoying the outdoors")
//        
//        let spaceSubtitle = state.generateAvatarSubtitle(
//            action: CharacterAction.relaxing,
//            location: CharacterLocation.space
//        )
//        #expect(spaceSubtitle == "Boldly going where no one has gone before")
//        
//        // Test default case
//        let defaultSubtitle = state.generateAvatarSubtitle(
//            action: CharacterAction.fighting,
//            location: CharacterLocation.desert
//        )
//        #expect(defaultSubtitle == "fighting in the desert")
//    }
//    
//    @Test func showImagePicker() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.showImagePicker(AvatarFormFeature.State.ImagePickerType.thumbnail)) {
//            $0.imagePickerType = AvatarFormFeature.State.ImagePickerType.thumbnail
//            $0.showingImagePicker = true
//        }
//        
//        await store.send(.hideImagePicker) {
//            $0.showingImagePicker = false
//        }
//        
//        await store.send(.showImagePicker(AvatarFormFeature.State.ImagePickerType.profileImage)) {
//            $0.imagePickerType = AvatarFormFeature.State.ImagePickerType.profileImage
//            $0.showingImagePicker = true
//        }
//    }
//    
//    @Test func imageURLSelected() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.thumbnailURLSelected("https://example.com/thumb.jpg")) {
//            $0.draft.thumbnailURL = "https://example.com/thumb.jpg"
//            $0.showingImagePicker = false
//        }
//        
//        await store.send(.profileImageURLSelected("https://example.com/profile.jpg")) {
//            $0.draft.profileImageURL = "https://example.com/profile.jpg"
//            $0.showingImagePicker = false
//        }
//    }
//    
//    @Test func cancelTapped() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.cancelTapped)
//        await store.receive(\.delegate.didCancel)
//    }
//}
