//
//  WelcomeFeatureDemoApp.swift
//  WelcomeFeatureDemo
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SharedModels
import SharingGRDB
import SwiftUI
import WelcomeFeature

@main
struct WelcomeFeatureDemoApp: App {
    @Dependency(\.context) var context

      init() {
        if context == .live {
          prepareDependencies {
            // swiftlint:disable force_try
            $0.defaultDatabase = try! appDatabase()
            // swiftlint:enable force_try
          }
        }
      }
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
