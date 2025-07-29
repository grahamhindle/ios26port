import Foundation

public extension Avatar {
    
    @MainActor static let mockAvatars: [Avatar] = [
        Avatar(
            id: 1,
            avatarId: "avatar_001",
            name: "Business Professional",
            subtitle: "Ready for meetings",
            characterOption: .man,
            characterAction: .working,
            characterLocation: .city,
            profileImageName: "avatar_business_man",
            profileImageURL: "https://picsum.photos/600/600",
            thumbnailURL: "https://picsum.photos/600/600",
            userId: 1,

            isPublic: true,
            dateCreated: Date(),
            dateModified: Date()
        ),
        Avatar(
            id: 2,
            avatarId: "avatar_002",
            name: "Casual Walker",
            subtitle: "Enjoying the park",
            characterOption: .woman,
            characterAction: .walking,
            characterLocation: .park,
            profileImageName: "avatar_casual_woman",
            profileImageURL: "https://picsum.photos/600/600",
            thumbnailURL: "https://picsum.photos/600/600",
            userId: 1,

            isPublic: true,
            dateCreated: Date().addingTimeInterval(-86400),
            dateModified: Date().addingTimeInterval(-3600)
        ),
        Avatar(
            id: 3,
            avatarId: "avatar_003",
            name: "Space Explorer",
            subtitle: "Boldly going",
            characterOption: .alien,
            characterAction: .relaxing,
            characterLocation: .space,
            profileImageName: "avatar_alien_space",
            profileImageURL: nil,
            thumbnailURL: nil,
            userId: 2,
            
            isPublic: false,
            dateCreated: Date().addingTimeInterval(-172800),
            dateModified: Date().addingTimeInterval(-172800)
        )
    ]
    
    @MainActor static let mockAvatar = mockAvatars[0]
}
