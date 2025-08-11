//
//  ExploreDemoApp.swift
//  ExploreDemo
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import Explore
import SwiftUI

@main
struct ExploreDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ExploreView(
                store: Store(initialState: ExploreFeature.State(userId: 1)) {
                    ExploreFeature()
                }
            )
        }
    }
}
