import Foundation

public extension Tag {
    @MainActor static let mockTags: [Tag] = [
        Tag(id: 1, name: "Professional"),
        Tag(id: 2, name: "Casual"),
        Tag(id: 3, name: "Business"),
        Tag(id: 4, name: "Outdoor"),
        Tag(id: 5, name: "Sci-Fi"),
        Tag(id: 6, name: "Fun"),
        Tag(id: 7, name: "Relaxed"),
        Tag(id: 8, name: "Active")
    ]
    
    @MainActor static let mockTag = mockTags[0]
}

public extension AvatarTag {
    @MainActor static let mockAvatarTags: [AvatarTag] = [
        AvatarTag(avatarId: 1, tagId: 1), // Business Professional - Professional
        AvatarTag(avatarId: 1, tagId: 3), // Business Professional - Business
        AvatarTag(avatarId: 2, tagId: 2), // Casual Walker - Casual
        AvatarTag(avatarId: 2, tagId: 4), // Casual Walker - Outdoor
        AvatarTag(avatarId: 2, tagId: 8), // Casual Walker - Active
        AvatarTag(avatarId: 3, tagId: 5), // Space Explorer - Sci-Fi
        AvatarTag(avatarId: 3, tagId: 6), // Space Explorer - Fun
        AvatarTag(avatarId: 3, tagId: 7)  // Space Explorer - Relaxed
    ]
    
    @MainActor static let mockAvatarTag = mockAvatarTags[0]
}
