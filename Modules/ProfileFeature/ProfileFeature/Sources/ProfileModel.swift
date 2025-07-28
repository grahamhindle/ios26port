import OSLog
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI

@Observable
public final class ProfileModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database

    // @ObservationIgnored
    // @FetchAll(Profile
    //     .order(by: \.fullName)
    // )
    // public var profiles: [Profile]
    @ObservationIgnored
    @FetchAll(
        Profile.order(by: \.membershipStatus),
        animation: .default
    )
    
    public var profiles: [Profile] = []

    public var profileForm: Profile.Draft?
    public var searchText = ""

    public init() {
        print("ProfileModel initialized")
    }

    public func deleteButtonTapped(profile: Profile) {
        withErrorReporting {
            try database.write { db in
                try Profile
                    .delete(profile)
                    .execute(db)
            }
        }
    }

    public func editButtonTapped(profile: Profile) {
        profileForm = Profile.Draft( profile)
    }

    public func addProfileButtonTapped() {
        profileForm = Profile.Draft(
            membershipStatus: .free,
            authorizationStatus: .guest,
            themeColorHex: 0x007A_FFFF,
            
        )
    }
}
