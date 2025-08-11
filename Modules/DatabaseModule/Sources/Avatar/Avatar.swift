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
    case general = "general"
    case custom = "custom"
    
    // Development & Technology
    case codeReview = "code_review"
    case debugging = "debugging"
    case refactoring = "refactoring"
    case architecture = "architecture"
    case testing = "testing"
    case optimization = "optimization"
    case learning = "learning"
    case problemSolving = "problem_solving"
    
    // Business & Professional
    case business = "business"
    case marketing = "marketing"
    case sales = "sales"
    case finance = "finance"
    case projectManagement = "project_management"
    case strategy = "strategy"
    case consulting = "consulting"
    case entrepreneurship = "entrepreneurship"
    
    // Travel & Lifestyle
    case travel = "travel"
    case food = "food"
    case health = "health"
    case fitness = "fitness"
    case cooking = "cooking"
    case gardening = "gardening"
    case homeImprovement = "home_improvement"
    case lifestyle = "lifestyle"
    
    // Creative & Arts
    case writing = "writing"
    case design = "design"
    case photography = "photography"
    case music = "music"
    case art = "art"
    case crafts = "crafts"
    case diy = "diy"
    case creativity = "creativity"
    
    // Education & Learning
    case education = "education"
    case research = "research"
    case academic = "academic"
    case language = "language"
    case skillDevelopment = "skill_development"
    case careerAdvice = "career_advice"
    case personalDevelopment = "personal_development"
    
    // Social & Communication
    case communication = "communication"
    case relationships = "relationships"
    case socialMedia = "social_media"
    case networking = "networking"
    case publicSpeaking = "public_speaking"
    case negotiation = "negotiation"
    
    // Technical & Science
    case science = "science"
    case engineering = "engineering"
    case dataAnalysis = "data_analysis"
    case ai = "ai"
    case machineLearning = "machine_learning"
    case cybersecurity = "cybersecurity"
    case blockchain = "blockchain"

    public var displayName: String {
        switch self {
        // General
        case .general: return "General"
        case .custom: return "Custom"
        
        // Development & Technology
        case .codeReview: return "Code Review"
        case .debugging: return "Debugging"
        case .refactoring: return "Refactoring"
        case .architecture: return "Architecture"
        case .testing: return "Testing"
        case .optimization: return "Optimization"
        case .learning: return "Learning"
        case .problemSolving: return "Problem Solving"
        
        // Business & Professional
        case .business: return "Business"
        case .marketing: return "Marketing"
        case .sales: return "Sales"
        case .finance: return "Finance"
        case .projectManagement: return "Project Management"
        case .strategy: return "Strategy"
        case .consulting: return "Consulting"
        case .entrepreneurship: return "Entrepreneurship"
        
        // Travel & Lifestyle
        case .travel: return "Travel"
        case .food: return "Food & Dining"
        case .health: return "Health"
        case .fitness: return "Fitness"
        case .cooking: return "Cooking"
        case .gardening: return "Gardening"
        case .homeImprovement: return "Home Improvement"
        case .lifestyle: return "Lifestyle"
        
        // Creative & Arts
        case .writing: return "Writing"
        case .design: return "Design"
        case .photography: return "Photography"
        case .music: return "Music"
        case .art: return "Art"
        case .crafts: return "Crafts"
        case .diy: return "DIY"
        case .creativity: return "Creativity"
        
        // Education & Learning
        case .education: return "Education"
        case .research: return "Research"
        case .academic: return "Academic"
        case .language: return "Language"
        case .skillDevelopment: return "Skill Development"
        case .careerAdvice: return "Career Advice"
        case .personalDevelopment: return "Personal Development"
        
        // Social & Communication
        case .communication: return "Communication"
        case .relationships: return "Relationships"
        case .socialMedia: return "Social Media"
        case .networking: return "Networking"
        case .publicSpeaking: return "Public Speaking"
        case .negotiation: return "Negotiation"
        
        // Technical & Science
        case .science: return "Science"
        case .engineering: return "Engineering"
        case .dataAnalysis: return "Data Analysis"
        case .ai: return "AI & ML"
        case .machineLearning: return "Machine Learning"
        case .cybersecurity: return "Cybersecurity"
        case .blockchain: return "Blockchain"
        }
    }
    
    public var icon: String {
        switch self {
        // General
        case .general: return "questionmark.circle"
        case .custom: return "pencil"
        
        // Development & Technology
        case .codeReview: return "doc.text.magnifyingglass"
        case .debugging: return "ladybug"
        case .refactoring: return "arrow.triangle.2.circlepath"
        case .architecture: return "building.2"
        case .testing: return "checkmark.shield"
        case .optimization: return "speedometer"
        case .learning: return "book"
        case .problemSolving: return "lightbulb"
        
        // Business & Professional
        case .business: return "briefcase"
        case .marketing: return "megaphone"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .finance: return "dollarsign.circle"
        case .projectManagement: return "list.clipboard"
        case .strategy: return "brain.head.profile"
        case .consulting: return "person.2"
        case .entrepreneurship: return "rocket"
        
        // Travel & Lifestyle
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .health: return "heart"
        case .fitness: return "figure.run"
        case .cooking: return "flame"
        case .gardening: return "leaf"
        case .homeImprovement: return "hammer"
        case .lifestyle: return "person.crop.circle"
        
        // Creative & Arts
        case .writing: return "pencil.and.outline"
        case .design: return "paintbrush"
        case .photography: return "camera"
        case .music: return "music.note"
        case .art: return "paintpalette"
        case .crafts: return "scissors"
        case .diy: return "wrench.and.screwdriver"
        case .creativity: return "sparkles"
        
        // Education & Learning
        case .education: return "graduationcap"
        case .research: return "magnifyingglass"
        case .academic: return "text.book.closed"
        case .language: return "character.bubble"
        case .skillDevelopment: return "person.badge.plus"
        case .careerAdvice: return "person.2.circle"
        case .personalDevelopment: return "person.crop.circle.badge.plus"
        
        // Social & Communication
        case .communication: return "message"
        case .relationships: return "heart.circle"
        case .socialMedia: return "network"
        case .networking: return "person.3"
        case .publicSpeaking: return "mic"
        case .negotiation: return "handshake"
        
        // Technical & Science
        case .science: return "atom"
        case .engineering: return "gearshape"
        case .dataAnalysis: return "chart.bar"
        case .ai: return "brain"
        case .machineLearning: return "cpu"
        case .cybersecurity: return "lock.shield"
        case .blockchain: return "link"
        }
    }
    
    public var group: CategoryGroup {
        switch self {
        case .general, .custom:
            return .general
        case .codeReview, .debugging, .refactoring, .architecture, .testing, .optimization, .learning, .problemSolving:
            return .development
        case .business, .marketing, .sales, .finance, .projectManagement, .strategy, .consulting, .entrepreneurship:
            return .business
        case .travel, .food, .health, .fitness, .cooking, .gardening, .homeImprovement, .lifestyle:
            return .lifestyle
        case .writing, .design, .photography, .music, .art, .crafts, .diy, .creativity:
            return .creative
        case .education, .research, .academic, .language, .skillDevelopment, .careerAdvice, .personalDevelopment:
            return .education
        case .communication, .relationships, .socialMedia, .networking, .publicSpeaking, .negotiation:
            return .social
        case .science, .engineering, .dataAnalysis, .ai, .machineLearning, .cybersecurity, .blockchain:
            return .technical
        }
    }
}

public enum CategoryGroup: String, CaseIterable {
    case general = "general"
    case development = "development"
    case business = "business"
    case lifestyle = "lifestyle"
    case creative = "creative"
    case education = "education"
    case social = "social"
    case technical = "technical"
    
    public var displayName: String {
        switch self {
        case .general: return "General"
        case .development: return "Development & Technology"
        case .business: return "Business & Professional"
        case .lifestyle: return "Travel & Lifestyle"
        case .creative: return "Creative & Arts"
        case .education: return "Education & Learning"
        case .social: return "Social & Communication"
        case .technical: return "Technical & Science"
        }
    }
    
    public var icon: String {
        switch self {
        case .general: return "questionmark.circle"
        case .development: return "laptopcomputer"
        case .business: return "briefcase"
        case .lifestyle: return "heart"
        case .creative: return "paintbrush"
        case .education: return "graduationcap"
        case .social: return "person.2"
        case .technical: return "gearshape"
        }
    }
}

// MARK: - Character Types (for future CharacterAction feature)
public enum PromptCharacterType: String, QueryBindable, CaseIterable {
    case expert = "expert"
    case mentor = "mentor"
    case consultant = "consultant"
    case teacher = "teacher"
    case coach = "coach"
    case advisor = "advisor"
    case specialist = "specialist"
    case professional = "professional"
    case enthusiast = "enthusiast"
    case ai = "ai"
    case custom = "custom"

    public var displayName: String {
        rawValue.capitalized
    }
    
    public var description: String {
        switch self {
        case .expert: return "Deep knowledge and experience"
        case .mentor: return "Patient teacher and guide"
        case .consultant: return "Strategic advisor and problem solver"
        case .teacher: return "Clear and structured educator"
        case .coach: return "Motivational and supportive guide"
        case .advisor: return "Wise counsel and recommendations"
        case .specialist: return "Focused expertise in specific area"
        case .professional: return "Formal and thorough approach"
        case .enthusiast: return "Passionate and energetic helper"
        case .ai: return "AI assistant with vast knowledge"
        case .custom: return "Custom character"
        }
    }
}

// MARK: - Character Moods (for future CharacterAction feature)
public enum PromptCharacterMood: String, QueryBindable, CaseIterable {
    case helpful = "helpful"
    case enthusiastic = "enthusiastic"
    case patient = "patient"
    case analytical = "analytical"
    case creative = "creative"
    case professional = "professional"
    case friendly = "friendly"
    case expert = "expert"
    case encouraging = "encouraging"
    case practical = "practical"
    case inspiring = "inspiring"
    case supportive = "supportive"

    public var displayName: String {
        rawValue.capitalized
    }
    
    public var description: String {
        switch self {
        case .helpful: return "Always ready to help"
        case .enthusiastic: return "Excited and energetic"
        case .patient: return "Takes time to explain"
        case .analytical: return "Focuses on logic and structure"
        case .creative: return "Thinks outside the box"
        case .professional: return "Formal and thorough"
        case .friendly: return "Casual and approachable"
        case .expert: return "Deep technical knowledge"
        case .encouraging: return "Motivational and positive"
        case .practical: return "Hands-on and actionable"
        case .inspiring: return "Uplifting and motivating"
        case .supportive: return "Understanding and caring"
        }
    }
}

// MARK: - Character Locations (for future CharacterAction feature)
public enum PromptCharacterLocation: String, QueryBindable, CaseIterable {
    case office = "office"
    case coffeeShop = "coffee_shop"
    case home = "home"
    case library = "library"
    case workshop = "workshop"
    case studio = "studio"
    case classroom = "classroom"
    case gym = "gym"
    case kitchen = "kitchen"
    case garden = "garden"
    case virtual = "virtual"
    case custom = "custom"

    public var displayName: String {
        switch self {
        case .office: return "Office"
        case .coffeeShop: return "Coffee Shop"
        case .home: return "Home"
        case .library: return "Library"
        case .workshop: return "Workshop"
        case .studio: return "Studio"
        case .classroom: return "Classroom"
        case .gym: return "Gym"
        case .kitchen: return "Kitchen"
        case .garden: return "Garden"
        case .virtual: return "Virtual Space"
        case .custom: return "Custom"
        }
    }
}

