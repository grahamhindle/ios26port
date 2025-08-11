//
//  BaseTestSuite.swift
//  AvatarFeature
//
//  Created by Graham Hindle on 04/08/2025.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
//import InlineSnapshotTesting
import DatabaseModule
import SharingGRDB
import Testing

@testable import AvatarFeature

/// Shared test database setup function for consistent database preparation across all test files
func prepareTestDatabase() throws -> any DatabaseWriter {
    let database = try withDependencies {
        $0.context = .test
    } operation: {
        try appDatabase()
    }
    prepareDependencies {
        $0.defaultDatabase = database
        $0.context = .test
    }
    return database
}

@MainActor
@Suite(
  
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.avatarStoreFactory, {
      Store(initialState: AvatarFeature.State()) { AvatarFeature() }
  })
)
struct BaseTestSuite {
    // ...
}
