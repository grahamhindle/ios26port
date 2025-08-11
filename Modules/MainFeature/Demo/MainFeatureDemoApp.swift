//
//  MainFeatureDemoApp.swift
//  MainFeature
//
//  Created by Graham Hindle on 07/29/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import MainFeature
import SwiftUI

@main
struct MainFeatureDemoApp: App {
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
            Text("MainFeature Demo")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
