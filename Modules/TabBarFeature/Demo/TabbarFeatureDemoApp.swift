//
//  TabbarDemoApp.swift
//  TabbarDemo
//
//  Created by Graham Hindle on 08/06/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import DatabaseModule
import SwiftUI
import TabBarFeature

@main
struct TabbarDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView(
                store: Store(initialState: TabBarFeature.State(user: User(
                    id: 1,
                    name: "Demo User",
                    email: "demo@example.com",
                    isAuthenticated: true,
                    membershipStatus: .free,
                    authorizationStatus: .authorized,
                    themeColorHex: 0x44a99ef_ff
                ))) {
                    TabBarFeature()
                }
            )
        }
    }
}
