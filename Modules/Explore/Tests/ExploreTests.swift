//
//  ExploreTests.swift
//  ExploreTests
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import Explore

@MainActor
final class ExploreTests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(initialState: ExploreFeature.State()) {
            ExploreFeature()
        }
        
        await store.send(.onAppear) {
            // Verify state changes if any
        }
        
        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
}
