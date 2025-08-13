//
//  DependencyAnalyzerTests.swift
//  DependencyAnalyzerTests
//
//  Created by Graham Hindle on 08/13/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import DependencyAnalyzer

@MainActor
final class DependencyAnalyzerTests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(initialState: DependencyAnalyzerFeature.State()) {
            DependencyAnalyzerFeature()
        }

        await store.send(.onAppear) {
            // Verify state changes if any
        }

        await store.receive(.onAppear) {
            // Verify any effects
        }
    }
}
