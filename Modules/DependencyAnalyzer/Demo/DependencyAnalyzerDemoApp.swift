//
//  DependencyAnalyzerDemoApp.swift
//  DependencyAnalyzerDemo
//
//  Created by Graham Hindle on 08/13/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import DependencyAnalyzer

@main
struct DependencyAnalyzerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DependencyAnalyzerView(
                store: Store(initialState: DependencyAnalyzerFeature.State()) {
                    DependencyAnalyzerFeature()
                }
            )
        }
    }
}
