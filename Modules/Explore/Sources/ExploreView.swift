//
//  ExploreView.swift
//  Explore
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct ExploreView: View {
    @Bindable var store: StoreOf<ExploreFeature>
    
    public init(store: StoreOf<ExploreFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text("Explore")
                .font(.title)
            
            Text("Feature View")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ExploreView(
        store: Store(initialState: ExploreFeature.State(userId: 1)) {
            ExploreFeature()
        }
    )
}
