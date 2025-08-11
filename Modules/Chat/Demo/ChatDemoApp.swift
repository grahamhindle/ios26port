//
//  ChatDemoApp.swift
//  ChatDemo
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import Chat
import ComposableArchitecture
import SwiftUI

@main
struct ChatDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView(
                store: Store(initialState: ChatFeature.State(userId: 1)) {
                    ChatFeature()
                }
            )
        }
    }
}
