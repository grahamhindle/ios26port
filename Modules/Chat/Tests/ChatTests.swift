//
//  ChatTests.swift
//  ChatTests
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

@testable import Chat
import ComposableArchitecture
import Testing

@Suite("Chat Feature Tests")
@MainActor
struct ChatTests {
    @Test("Chat feature initializes correctly")
    func chatFeatureInitialization() async {
        let store = TestStore(initialState: ChatFeature.State(userId: 123)) {
            ChatFeature()
        }

        #expect(store.state.userId == 123)
    }

    @Test("OnAppear action")
    func onAppearAction() async {
        let store = TestStore(initialState: ChatFeature.State(userId: 123)) {
            ChatFeature()
        }

        await store.send(.onAppear)
    }
}
