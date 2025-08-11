//
//  WelcomeFeatureTests.swift
//  WelcomeFeatureTests
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
@testable import WelcomeFeature
import XCTest

@MainActor
final class WelcomeFeatureTests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(initialState: WelcomeFeatureFeature.State()) {
            WelcomeFeatureFeature()
        }

        await store.send(.onAppear) {
            // Verify state changes if any
        }

        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
}
