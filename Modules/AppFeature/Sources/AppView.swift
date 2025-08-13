//
//  AppView.swift
//  AppFeature
//
//  Created by Graham Hindle on 10/08/2025.
//

import ComposableArchitecture
import DatabaseModule
import SharingGRDB
import SwiftUI
import TabBarFeature
import WelcomeFeature

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let store = store.scope(state: \.welcomeState, action: \.welcome) {
                WelcomeView(store: store)
            } else if let store = store.scope(state: \.tabBarState, action: \.tabBar) {
                TabBarView(store: store)
            } else {
                // Loading state while checking authentication
                ProgressView("Loading...")

            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    // swiftlint:disable redundant_discardable_let
   let _ = prepareDependencies {
        do {
            $0.defaultDatabase = try withDependencies {
                $0.context = .preview
            } operation: {
                try appDatabase()
            }
            $0.context = .preview
        } catch {
            print("Failed to prepare database for preview: \(error)")
        }
    }
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    NavigationStack {
        AppView(store: store)
    }
    // swiftlint:enable redundant_discardable_let
}
