//
//  TabbarFeatureTests.swift
//  TabbarTests
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
@testable import Tabbar
import XCTest

@MainActor
final class TabbarTests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(initialState: TabBarFeature.State()) {
            TabBarFeature()
        }

        await store.send(.onAppear) {
            // Verify state changes if any
        }

        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
}
