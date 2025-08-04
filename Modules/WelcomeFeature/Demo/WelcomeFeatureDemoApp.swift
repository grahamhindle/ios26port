//
//  WelcomeFeatureDemoApp.swift
//  WelcomeFeatureDemo
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import WelcomeFeature

@main
struct WelcomeFeatureDemoApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView(
                store: Store(initialState: WelcomeFeature.State()) {
                    WelcomeFeature()
                }
            )
        }
    }
}
