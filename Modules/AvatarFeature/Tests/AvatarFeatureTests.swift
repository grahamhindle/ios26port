//
//  AvatarFeatureTests.swift
//  AvatarFeatureTests
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import Dependencies
import DependenciesTestSupport
import Foundation
import GRDB
import SharedModels
import SharingGRDB
import Testing
@testable import AvatarFeature

@MainActor
struct AvatarFeatureTests {
    
    // MARK: - AvatarFeature Tests
    
    @Test func initialState() async throws {
        prepareDependencies {
            $0.context = .test
            do {
                $0.defaultDatabase = try appDatabase()
            } catch {
                fatalError("Database failed to initialize: \(error)")
            }
            $0.currentUserId = { 1 }
        }
        
        let state = AvatarFeature.State()
        #expect(state.detailType == .all)
        #expect(state.avatarForm == nil)
        #expect(state.filteredAvatarRecords.isEmpty)
    }
    
    @Test func detailTypeProperties() async throws {
        #expect(AvatarFeature.DetailType.all.title == "All")
        #expect(AvatarFeature.DetailType.publicAvatars.title == "Public")
        #expect(AvatarFeature.DetailType.privateAvatars.title == "Private")
        
        #expect(AvatarFeature.DetailType.all.color == .green)
        #expect(AvatarFeature.DetailType.publicAvatars.color == .blue)
        #expect(AvatarFeature.DetailType.privateAvatars.color == .red)
    }
    
    // TODO: Fix TestStore Reducer conformance issue
    // @Test func addButtonTapped() async throws {
    //     let store = TestStore(initialState: AvatarFeature.State()) {
    //         AvatarFeature()
    //     } withDependencies: {
    //         $0.defaultDatabase = .testValue
    //         $0.currentUserId = { 42 }
    //     }
    //     
    //     await store.send(.addButtonTapped) {
    //         $0.avatarForm = AvatarFormFeature.State(
    //             draft: Avatar.Draft(name: "", userId: 42, isPublic: true)
    //         )
    //     }
    // }
    
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
//        } withDependencies: {
//            $0.currentUserId = { 1 }
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
//        await store.send(.avatarForm(.presented(.delegate(.didFinish)))) {
//            $0.avatarForm = nil
//        }
//    }
//    
//    @Test func avatarFormDelegateDidCancel() async throws {
//        let store = TestStore(initialState: AvatarFeature.State()) {
//            AvatarFeature()
//        } withDependencies: {
//            $0.currentUserId = { 1 }
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
//        await store.send(.avatarForm(.presented(.delegate(.didCancel)))) {
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
//    
//    // MARK: - AvatarFormFeature Tests
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
//        await store.send(.characterOptionChanged(.man)) {
//            $0.draft.characterOption = .man
//            $0.updateGeneratedName()
//            $0.updateGeneratedSubtitle()
//        }
//        
//        await store.send(.characterActionChanged(.working)) {
//            $0.draft.characterAction = .working
//            $0.updateGeneratedName()
//            $0.updateGeneratedSubtitle()
//        }
//        
//        await store.send(.characterLocationChanged(.city)) {
//            $0.draft.characterLocation = .city
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
//            option: .man,
//            action: .working,
//            location: .city
//        )
//        #expect(businessProfessional == "Business Professional")
//        
//        let casualWalker = state.generateAvatarName(
//            option: .woman,
//            action: .walking,
//            location: .park
//        )
//        #expect(casualWalker == "Casual Walker")
//        
//        let spaceExplorer = state.generateAvatarName(
//            option: .alien,
//            action: .relaxing,
//            location: .space
//        )
//        #expect(spaceExplorer == "Space Explorer")
//        
//        // Test default case
//        let defaultName = state.generateAvatarName(
//            option: .dog,
//            action: .eating,
//            location: .desert
//        )
//        #expect(defaultName == "eating Dog")
//    }
//    
//    @Test func generateAvatarSubtitle() async throws {
//        let state = AvatarFormFeature.State(draft: Avatar.Draft())
//        
//        let businessSubtitle = state.generateAvatarSubtitle(
//            action: .working,
//            location: .city
//        )
//        #expect(businessSubtitle == "Ready for meetings")
//        
//        let walkingSubtitle = state.generateAvatarSubtitle(
//            action: .walking,
//            location: .park
//        )
//        #expect(walkingSubtitle == "Enjoying the outdoors")
//        
//        let spaceSubtitle = state.generateAvatarSubtitle(
//            action: .relaxing,
//            location: .space
//        )
//        #expect(spaceSubtitle == "Boldly going where no one has gone before")
//        
//        // Test default case
//        let defaultSubtitle = state.generateAvatarSubtitle(
//            action: .fighting,
//            location: .desert
//        )
//        #expect(defaultSubtitle == "fighting in the desert")
//    }
//    
//    @Test func showImagePicker() async throws {
//        let store = TestStore(initialState: AvatarFormFeature.State(draft: Avatar.Draft())) {
//            AvatarFormFeature()
//        }
//        
//        await store.send(.showImagePicker(.thumbnail)) {
//            $0.imagePickerType = .thumbnail
//            $0.showingImagePicker = true
//        }
//        
//        await store.send(.hideImagePicker) {
//            $0.showingImagePicker = false
//        }
//        
//        await store.send(.showImagePicker(.profileImage)) {
//            $0.imagePickerType = .profileImage
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
//        await store.receive(.delegate(.didCancel))
//    }
}
