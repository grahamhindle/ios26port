//
//  MainDemoApp.swift
//  Main
//
//  Created by Graham Hindle on 07/21/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import SwiftUI
import Main

@main
struct MainDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Main Demo")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}