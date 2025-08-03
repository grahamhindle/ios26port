import Foundation
import SharingGRDB

@Table("avatar")
public struct Avatar: Equatable, Identifiable, Sendable {
    public let id: Int
    public var avatarId: String?
    public var name: String
    public var subtitle: String?
    public var characterOption: CharacterOption?
    public var characterAction: CharacterAction?
    public var characterLocation: CharacterLocation?
    public var profileImageName: String?
    public var profileImageURL: String?
    public var thumbnailURL: String?
    public let userId: User.ID
    public var isPublic: Bool
    public let dateCreated: Date?
    public let dateModified: Date?
    

    
    public init(
        id: Int = 0,
        avatarId: String? = nil,
        name: String = "",
        subtitle: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        profileImageURL: String? = nil,
        thumbnailURL: String? = nil,
        userId: User.ID,
        isPublic: Bool = true,
        dateCreated: Date? = Date(),
        dateModified: Date? = nil
    ) {
        self.id = id
        self.avatarId = avatarId
        self.name = name
        self.subtitle = subtitle
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.profileImageURL = profileImageURL
        self.thumbnailURL = thumbnailURL
        self.userId = userId
        self.isPublic = isPublic
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        
      
    }
}
extension Avatar.Draft: Equatable, Identifiable, Sendable {}



// MARK: - Database Relations
// Note: Relationships will be handled through queries rather than GRDB associations

public enum CharacterOption: String, QueryBindable, CaseIterable {
    case man, woman, alien, dog, cat, other

    public var displayName: String {
        rawValue.capitalized
    }
}



public enum CharacterAction: String,  QueryBindable, CaseIterable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing,
         fighting, crying

    public var displayName: String {
        rawValue.capitalized
    }
}


public enum CharacterLocation: String, QueryBindable, CaseIterable {
    case city, park, museum, mall, desert, forest, space

    public var displayName: String {
        rawValue.capitalized
    }
}


