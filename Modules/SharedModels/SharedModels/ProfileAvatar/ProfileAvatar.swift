import Foundation
import SharingGRDB

@Table("profile_avatar")
public struct ProfileAvatar: Equatable, Identifiable, Sendable {
    public let id: Int
    public let profileID: Profile.ID
    public let avatarID: Avatar.ID
    public let dateAdded: Date?
    public let isPrimary: Bool
    
    public init(
        id: Int = 0,
        profileID: Profile.ID,
        avatarID: Avatar.ID,
        dateAdded: Date? = Date(),
        isPrimary: Bool = false
    ) {
        self.id = id
        self.profileID = profileID
        self.avatarID = avatarID
        self.dateAdded = dateAdded
        self.isPrimary = isPrimary
    }
}

// MARK: - Database Relations

//extension ProfileAvatar {
//    public static var profile: BelongsTo<Profile> {
//        belongsTo(Profile.self, key: "profileID")
//    }
//    
//    public static var avatar: BelongsTo<Avatar> {
//        belongsTo(Avatar.self, key: "avatarID")
//    }
//}

//// MARK: - Convenience Methods
//
//extension ProfileAvatar {
//    /// Get all avatars for a specific profile
//    public static func avatarsForProfile(_ profileID: Profile.ID) -> QueryInterfaceRequest<Avatar> {
//        Avatar.joining(required: ProfileAvatar.filter(Column("profileID") == profileID))
//    }
//    
//    /// Get all profiles for a specific avatar
//    public static func profilesForAvatar(_ avatarID: Avatar.ID) -> QueryInterfaceRequest<Profile> {
//        Profile.joining(required: ProfileAvatar.filter(Column("avatarID") == avatarID))
//    }
//}
