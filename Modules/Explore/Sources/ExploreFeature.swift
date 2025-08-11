//
//  ExploreFeature.swift
//  Explore
//
//  Created by Graham Hindle on 08/07/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ExploreFeature {
    public init() {}

    @ObservableState
    public struct State: Sendable, Equatable {
        public var userId: Int

        public init(userId: Int) {
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
