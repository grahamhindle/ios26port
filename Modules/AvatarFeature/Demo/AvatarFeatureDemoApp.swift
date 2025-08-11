//
//  AvatarFeatureDemoApp.swift
//  AvatarFeature
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//
import AvatarFeature
import ComposableArchitecture
import DatabaseModule
import Foundation
import SwiftUI

@main
struct AvatarFeatureDemoApp: App {
    let store: StoreOf<AvatarFeature>

    init() {
        prepareDependencies {
            do {
                $0.defaultDatabase = try appDatabase()
                print("✅ Database initialized for AvatarFeature demo")
            } catch {
                fatalError("Database failed to initialize: \(error)")
            }
        }
        store = Store(initialState: AvatarFeature.State()) {
            AvatarFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            AvatarView(store: store)
        }
    }
}
