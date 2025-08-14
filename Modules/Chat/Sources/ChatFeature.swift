//
//  ChatFeature.swift
//  Chat
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ChatFeature {
    public init() {}

    @ObservableState
    public struct State: Sendable, Equatable {
        public var userId: UUID
        public init(userId: UUID) {
            self.userId = userId
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                .none
            }
        }
    }
}
