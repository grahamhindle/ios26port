//
//  WelcomeFeatureFeature.swift
//  WelcomeFeature
//
//  Created by Graham Hindle on 08/04/25.
//  Copyright © 2025 grahamhindle. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct WelcomeFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case signInTapped
        case startTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                case .signInTapped:
                print("Signin")
                return .none
                case .startTapped:
                print("Start")
                return .none
            }
        }
    }
}
