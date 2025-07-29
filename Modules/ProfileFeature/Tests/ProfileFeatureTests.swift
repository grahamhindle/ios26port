//
//  ProfileFeatureTests.swift
//  ProfileFeatureTests
//
//  Created by Graham Hindle on 19/07/2025.
//

import CustomDump
import DependenciesTestSupport
import InlineSnapshotTesting
import SnapshotTestingCustomDump
import Testing
import SharedModels

@testable import ProfileFeature

@Suite(
    .dependency(\.defaultDatabase, try! appDatabase()),
       .snapshots(record: .failed )
)
struct ProfileFeatureTests {

    @Test func deletion() async throws{
        let model = ProfileModel()
        try await model.$profileRows.load()

        assertInlineSnapshot(of: model.profileRows, as: .customDump) {
            """
            [
              [0]: ProfileModel.ProfileRowData(
                avatarCount: 0,
                profile: Profile(
                  id: 3,
                  fullName: "Alice Smith",
                  email: "alice.smith@example.com",
                  dateOfBirth: nil,
                  themeColorHex: 682051071,
                  avatarID: 1
                )
              ),
              [1]: ProfileModel.ProfileRowData(
                avatarCount: 3,
                profile: Profile(
                  id: 1,
                  fullName: "Graham",
                  email: "user123@example.com",
                  dateOfBirth: nil,
                  themeColorHex: 4283905023,
                  avatarID: 1
                )
              ),
              [2]: ProfileModel.ProfileRowData(
                avatarCount: 0,
                profile: Profile(
                  id: 2,
                  fullName: "Jane Doe",
                  email: "jane.doe@example.com",
                  dateOfBirth: nil,
                  themeColorHex: 1116206591,
                  avatarID: 1
                )
              )
            ]
            """
        }
        model.deleteButtonTapped(profile: model.profileRows[0].profile)
        try await model.$profileRows.load()


        assertInlineSnapshot(of: model.profileRows, as: .customDump) {
            """
            [
              [0]: ProfileModel.ProfileRowData(
                avatarCount: 3,
                profile: Profile(
                  id: 1,
                  fullName: "Graham",
                  email: "user123@example.com",
                  dateOfBirth: nil,
                  themeColorHex: 4283905023,
                  avatarID: 1
                )
              )
            ]
            """
        }

    }
}

