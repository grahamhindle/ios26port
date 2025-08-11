import Foundation
import SharingGRDB

@Table("avatar")
public struct Avatar: Equatable, Hashable, Identifiable, Sendable {
    public let id: Int
    public var avatarId: String?
    public var name: String
    public var subtitle: String?

    // Prompt-based character fields
    public var promptCategory: PromptCategory?
    public var promptCharacterType: PromptCharacterType?
    public var promptCharacterMood: PromptCharacterMood?
    public var profileImageName: String?
    public var profileImageURL: String?
    public var thumbnailURL: String?
    public var generatedPrompt: String?
    public let userId: User.ID
    public var isPublic: Bool
    public let dateCreated: Date?
    public let dateModified: Date?

    public init(
        id: Int = 0,
        avatarId: String? = nil,
        name: String = "",
        subtitle: String? = nil,

        promptCategory: PromptCategory? = nil,
        promptCharacterType: PromptCharacterType? = nil,
        promptCharacterMood: PromptCharacterMood? = nil,
        profileImageName: String? = nil,
        profileImageURL: String? = nil,
        thumbnailURL: String? = nil,
        generatedPrompt: String? = nil,
        userId: User.ID,
        isPublic: Bool = true,
        dateCreated: Date? = Date(),
        dateModified: Date? = nil
    ) {
        self.id = id
        self.avatarId = avatarId
        self.name = name
        self.subtitle = subtitle

        self.promptCategory = promptCategory
        self.promptCharacterType = promptCharacterType
        self.promptCharacterMood = promptCharacterMood
        self.profileImageName = profileImageName
        self.profileImageURL = profileImageURL
        self.thumbnailURL = thumbnailURL
        self.generatedPrompt = generatedPrompt
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

// MARK: - Prompt Categories (for future CharacterAction feature)

public enum PromptCategory: String, QueryBindable, CaseIterable {
    // General
    case general
    case custom

    // Development & Technology
    case codeReview = "code_review"
    case debugging
    case refactoring
    case architecture
    case testing
    case optimization
    case learning
    case problemSolving = "problem_solving"

    // Business & Professional
    case business
    case marketing
    case sales
    case finance
    case projectManagement = "project_management"
    case strategy
    case consulting
    case entrepreneurship

    // Travel & Lifestyle
    case travel
    case food
    case health
    case fitness
    case cooking
    case gardening
    case homeImprovement = "home_improvement"
    case lifestyle

    // Creative & Arts
    case writing
    case design
    case photography
    case music
    case art
    case crafts
    case diy
    case creativity

    // Education & Learning
    case education
    case research
    case academic
    case language
    case skillDevelopment = "skill_development"
    case careerAdvice = "career_advice"
    case personalDevelopment = "personal_development"

    // Social & Communication
    case communication
    case relationships
    case socialMedia = "social_media"
    case networking
    case publicSpeaking = "public_speaking"
    case negotiation

    // Technical & Science
    case science
    case engineering
    case dataAnalysis = "data_analysis"
    case aiAssistant = "ai"
    case machineLearning = "machine_learning"
    case cybersecurity
    case blockchain

    public var displayName: String {
        switch self {
        // General
        case .general: "General"
        case .custom: "Custom"
        // Development & Technology
        case .codeReview: "Code Review"
        case .debugging: "Debugging"
        case .refactoring: "Refactoring"
        case .architecture: "Architecture"
        case .testing: "Testing"
        case .optimization: "Optimization"
        case .learning: "Learning"
        case .problemSolving: "Problem Solving"
        // Business & Professional
        case .business: "Business"
        case .marketing: "Marketing"
        case .sales: "Sales"
        case .finance: "Finance"
        case .projectManagement: "Project Management"
        case .strategy: "Strategy"
        case .consulting: "Consulting"
        case .entrepreneurship: "Entrepreneurship"
        // Travel & Lifestyle
        case .travel: "Travel"
        case .food: "Food & Dining"
        case .health: "Health"
        case .fitness: "Fitness"
        case .cooking: "Cooking"
        case .gardening: "Gardening"
        case .homeImprovement: "Home Improvement"
        case .lifestyle: "Lifestyle"
        // Creative & Arts
        case .writing: "Writing"
        case .design: "Design"
        case .photography: "Photography"
        case .music: "Music"
        case .art: "Art"
        case .crafts: "Crafts"
        case .diy: "DIY"
        case .creativity: "Creativity"
        // Education & Learning
        case .education: "Education"
        case .research: "Research"
        case .academic: "Academic"
        case .language: "Language"
        case .skillDevelopment: "Skill Development"
        case .careerAdvice: "Career Advice"
        case .personalDevelopment: "Personal Development"
        // Social & Communication
        case .communication: "Communication"
        case .relationships: "Relationships"
        case .socialMedia: "Social Media"
        case .networking: "Networking"
        case .publicSpeaking: "Public Speaking"
        case .negotiation: "Negotiation"
        // Technical & Science
        case .science: "Science"
        case .engineering: "Engineering"
        case .dataAnalysis: "Data Analysis"
        case .aiAssistant: "AI & ML"
        case .machineLearning: "Machine Learning"
        case .cybersecurity: "Cybersecurity"
        case .blockchain: "Blockchain"
        }
    }

    public var icon: String {
        switch self {
        // General
        case .general: "questionmark.circle"
        case .custom: "pencil"
        // Development & Technology
        case .codeReview: "doc.text.magnifyingglass"
        case .debugging: "ladybug"
        case .refactoring: "arrow.triangle.2.circlepath"
        case .architecture: "building.2"
        case .testing: "checkmark.shield"
        case .optimization: "speedometer"
        case .learning: "book"
        case .problemSolving: "lightbulb"
        // Business & Professional
        case .business: "briefcase"
        case .marketing: "megaphone"
        case .sales: "chart.line.uptrend.xyaxis"
        case .finance: "dollarsign.circle"
        case .projectManagement: "list.clipboard"
        case .strategy: "brain.head.profile"
        case .consulting: "person.2"
        case .entrepreneurship: "rocket"
        // Travel & Lifestyle
        case .travel: "airplane"
        case .food: "fork.knife"
        case .health: "heart"
        case .fitness: "figure.run"
        case .cooking: "flame"
        case .gardening: "leaf"
        case .homeImprovement: "hammer"
        case .lifestyle: "person.crop.circle"
        // Creative & Arts
        case .writing: "pencil.and.outline"
        case .design: "paintbrush"
        case .photography: "camera"
        case .music: "music.note"
        case .art: "paintpalette"
        case .crafts: "scissors"
        case .diy: "wrench.and.screwdriver"
        case .creativity: "sparkles"
        // Education & Learning
        case .education: "graduationcap"
        case .research: "magnifyingglass"
        case .academic: "text.book.closed"
        case .language: "character.bubble"
        case .skillDevelopment: "person.badge.plus"
        case .careerAdvice: "person.2.circle"
        case .personalDevelopment: "person.crop.circle.badge.plus"
        // Social & Communication
        case .communication: "message"
        case .relationships: "heart.circle"
        case .socialMedia: "network"
        case .networking: "person.3"
        case .publicSpeaking: "mic"
        case .negotiation: "handshake"
        // Technical & Science
        case .science: "atom"
        case .engineering: "gearshape"
        case .dataAnalysis: "chart.bar"
        case .aiAssistant: "brain"
        case .machineLearning: "cpu"
        case .cybersecurity: "lock.shield"
        case .blockchain: "link"
        }
    }

    public var group: CategoryGroup {
        switch self {
        case .general, .custom:
            .general
        case .codeReview, .debugging, .refactoring, .architecture, .testing, .optimization, .learning, .problemSolving:
            .development
        case .business, .marketing, .sales, .finance, .projectManagement, .strategy, .consulting, .entrepreneurship:
            .business
        case .travel, .food, .health, .fitness, .cooking, .gardening, .homeImprovement, .lifestyle:
            .lifestyle
        case .writing, .design, .photography, .music, .art, .crafts, .diy, .creativity:
            .creative
        case .education, .research, .academic, .language, .skillDevelopment, .careerAdvice, .personalDevelopment:
            .education
        case .communication, .relationships, .socialMedia, .networking, .publicSpeaking, .negotiation:
            .social
        case .science, .engineering, .dataAnalysis, .aiAssistant, .machineLearning, .cybersecurity, .blockchain:
            .technical
        }
    }
}

public enum CategoryGroup: String, CaseIterable {
    case general
    case development
    case business
    case lifestyle
    case creative
    case education
    case social
    case technical

    public var displayName: String {
        switch self {
        case .general: "General"
        case .development: "Development & Technology"
        case .business: "Business & Professional"
        case .lifestyle: "Travel & Lifestyle"
        case .creative: "Creative & Arts"
        case .education: "Education & Learning"
        case .social: "Social & Communication"
        case .technical: "Technical & Science"
        }
    }

    public var icon: String {
        switch self {
        case .general: "questionmark.circle"
        case .development: "laptopcomputer"
        case .business: "briefcase"
        case .lifestyle: "heart"
        case .creative: "paintbrush"
        case .education: "graduationcap"
        case .social: "person.2"
        case .technical: "gearshape"
        }
    }
}

// MARK: - Character Types (for future CharacterAction feature)

public enum PromptCharacterType: String, QueryBindable, CaseIterable {
    case expert
    case mentor
    case consultant
    case teacher
    case coach
    case advisor
    case specialist
    case professional
    case enthusiast
    case aiAssistant = "ai"
    case custom

    public var displayName: String {
        rawValue.capitalized
    }

    public var description: String {
        switch self {
        case .expert: "Deep knowledge and experience"
        case .mentor: "Patient teacher and guide"
        case .consultant: "Strategic advisor and problem solver"
        case .teacher: "Clear and structured educator"
        case .coach: "Motivational and supportive guide"
        case .advisor: "Wise counsel and recommendations"
        case .specialist: "Focused expertise in specific area"
        case .professional: "Formal and thorough approach"
        case .enthusiast: "Passionate and energetic helper"
        case .aiAssistant: "AI assistant with vast knowledge"
        case .custom: "Custom character"
        }
    }
}

// MARK: - Character Moods (for future CharacterAction feature)

public enum PromptCharacterMood: String, QueryBindable, CaseIterable {
    case helpful
    case enthusiastic
    case patient
    case analytical
    case creative
    case professional
    case friendly
    case expert
    case encouraging
    case practical
    case inspiring
    case supportive

    public var displayName: String {
        rawValue.capitalized
    }

    public var description: String {
        switch self {
        case .helpful: "Always ready to help"
        case .enthusiastic: "Excited and energetic"
        case .patient: "Takes time to explain"
        case .analytical: "Focuses on logic and structure"
        case .creative: "Thinks outside the box"
        case .professional: "Formal and thorough"
        case .friendly: "Casual and approachable"
        case .expert: "Deep technical knowledge"
        case .encouraging: "Motivational and positive"
        case .practical: "Hands-on and actionable"
        case .inspiring: "Uplifting and motivating"
        case .supportive: "Understanding and caring"
        }
    }
}

// MARK: - Character Locations (for future CharacterAction feature)

public enum PromptCharacterLocation: String, QueryBindable, CaseIterable {
    case office
    case coffeeShop = "coffee_shop"
    case home
    case library
    case workshop
    case studio
    case classroom
    case gym
    case kitchen
    case garden
    case virtual
    case custom

    public var displayName: String {
        switch self {
        case .office: "Office"
        case .coffeeShop: "Coffee Shop"
        case .home: "Home"
        case .library: "Library"
        case .workshop: "Workshop"
        case .studio: "Studio"
        case .classroom: "Classroom"
        case .gym: "Gym"
        case .kitchen: "Kitchen"
        case .garden: "Garden"
        case .virtual: "Virtual Space"
        case .custom: "Custom"
        }
    }
}

// MARK: - Selection Structs

@Selection
public struct PopularAvatar: Equatable, Sendable {
    public let avatar: Avatar
}

@Selection
public struct AvatarRecords: Equatable, Sendable {
    public let avatar: Avatar
}
