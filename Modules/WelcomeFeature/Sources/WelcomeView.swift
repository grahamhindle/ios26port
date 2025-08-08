//
//  WelcomeView.swift
//  WelcomeFeature
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI
import UIComponents

public struct WelcomeView: View {
    @Bindable var store: StoreOf<WelcomeFeature>

    public init(store: StoreOf<WelcomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                AsyncImageView(avatarURL: URL(string: "https://picsum.photos/600/600"))
                    .ignoresSafeArea(.all, edges: [.top])
                VStack(spacing: 8) {
                    Text(SharedStrings.welcome)
                        .font(SharedFonts.largeTitle)
                        .fontWeight(.semibold)
                    Text(SharedStrings.youtube)
                        .font(SharedFonts.caption)
                        .foregroundStyle(SharedColors.secondary)
                }

                VStack(spacing: SharedLayout.smallPadding) {
                    Text(SharedStrings.getStarted)
                        .anyButton(.callToAction) {
                            store.send(.startTapped)
                        }

                    Text(SharedStrings.alreadyHaveAnAccount)
                        .underline()
                        .font(SharedFonts.body)
                        .padding(SharedLayout.smallPadding)
                        .background(SharedColors.tappableBackground)
                        .onTapGesture {
                            store.send(.signInTapped)
                        }
                }

                HStack {
                    if let termsURL = URL(string: SharedURLStrings.termsOfService) {
                        Link(destination: termsURL) {
                            Text(SharedStrings.termsOfService)
                        }
                    }
                    if let privacyURL = URL(string: SharedURLStrings.privacyPolicy) {
                        Link(destination: privacyURL) {
                            Text(SharedStrings.privacyPolicy)
                        }
                    }
                }
                // .frame(width: 100, height: 100)
            }

            // .padding(SharedLayout.padding)
        }
    }
}

#Preview("Welcome - Default") {
    // Set up dependencies BEFORE creating Store/State
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
    
    // Now create Store with properly initialized dependencies
    let store = Store(initialState: WelcomeFeature.State()) {
        WelcomeFeature()
    }
    
    NavigationStack {
        WelcomeView(store: store)
    }
}

#Preview("Welcome - Creating Guest") {
    // Set up dependencies BEFORE creating Store/State
    let _: Void = prepareDependencies {
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
    
    // Create initial state with guest creation in progress
    var initialState = WelcomeFeature.State()
    initialState.isCreatingGuestUser = true
    
    let store = Store(initialState: initialState) {
        WelcomeFeature()
    }
    
    return NavigationStack {
        WelcomeView(store: store)
    }
}
