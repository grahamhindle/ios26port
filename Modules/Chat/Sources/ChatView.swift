//
//  ChatView.swift
//  Chat
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct ChatView: View {
    @Bindable var store: StoreOf<ChatFeature>

    public init(store: StoreOf<ChatFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text("Chat")
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
    ChatView(
        store: Store(initialState: ChatFeature.State(userId: UUID(0))) {
            ChatFeature()
        }
    )
}
