//
//  ProfileRow.swift
//  DatabaseUser
//
//  Created by Graham Hindle on 16/07/2025.
//

import SharedModels
import SharedResources
import SwiftUI


public struct ProfileRow: View {
    let profile: Profile
    public init(profile: Profile) {
        self.profile = profile
    }
    public var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundStyle(Color(hex: profile.themeColorHex))
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.membershipStatus.rawValue)
                    .font(.headline)
                Text(profile.authorizationStatus.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}



//#Preview {
//  List {
//    ProfileDetailRow(profileRowData: ProfileModel.ProfileRowData(
//      id: 1,
//      fullName: "John Doe",
//      email: "john.doe@example.com",
//      dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15)),
//      themeColorHex: 0xef7e4a_ff,
//      avatarID: 1
//
//    ))
//    ProfileRow(avatar: Avatar, profile: Profile(
//      id: 2,
//      fullName: "Jane Smith",
//      email: "jane.smith@example.com",
//      dateOfBirth: Calendar.current.date(from: DateComponents(year: 1985, month: 8, day: 22)),
//      themeColorHex: 0x4a99ef_ff,
//      avatarID: 1
//    ))
//    ProfileRow(avatar: Avatar, profile: Profile(
//      id: 3,
//      fullName: "Bob Johnson",
//      email: "bob.johnson@example.com",
//      dateOfBirth: nil,
//      themeColorHex: 0x7ee04a_ff,
//      avatarID: 2
//
//
//    ))
//  }
//}
