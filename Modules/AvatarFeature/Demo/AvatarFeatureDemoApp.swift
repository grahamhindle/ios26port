//
//  AvatarFeatureDemoApp.swift
//  AvatarFeature
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import SwiftUI
import AvatarFeature
import SharedModels
import SharingGRDB

@main
struct AvatarFeatureDemoApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            AvatarView()
        }
    }
}
