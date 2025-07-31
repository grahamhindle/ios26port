import OSLog

import SharingGRDB



public func appDatabase() throws -> any DatabaseWriter {
   
    @Dependency(\.context) var context
    let database: any DatabaseWriter

      var configuration = Configuration()
      configuration.foreignKeysEnabled = true
      configuration.prepareDatabase { db in
        #if DEBUG
          db.trace(options: .profile) {
            if context == .preview {
              print($0.expandedDescription)
            } else {
              logger.debug("\($0.expandedDescription)")
            }
          }
        #endif
      }



    switch context {
      case .live:
        let path = URL.documentsDirectory.appending(component: "dbChats.sqlite").path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
      case .preview, .test:
        database = try DatabaseQueue(configuration: configuration)
      }

      
      var migrator = DatabaseMigrator()
      #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
      #endif
      migrator.registerMigration("Create initial tables") { db in
        print("🔥 Creating tables for new entity model...")
        
        // Users table - Consolidated with auth and profile data
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dateOfBirth TEXT,
            email TEXT,
            dateCreated TEXT,
            lastSignedInDate TEXT,
            authId TEXT,
            isAuthenticated INTEGER NOT NULL DEFAULT 0,
            providerID TEXT,
            membershipStatus TEXT NOT NULL DEFAULT 'free',
            authorizationStatus TEXT NOT NULL DEFAULT 'guest',
            themeColorHex INTEGER NOT NULL DEFAULT \(raw: 0x44a99ef_ff),
            profileCreatedAt TEXT,
            profileUpdatedAt TEXT
            ) STRICT
            """
        ).execute(db)
        print("🔥 Users table created successfully")
        
        // Guest table - For non-authenticated users
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS guest (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userID INTEGER NOT NULL,
            sessionID TEXT NOT NULL UNIQUE,
            expiresAt TEXT NOT NULL,
            createdAt TEXT,
            FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE
            ) STRICT
            """
        ).execute(db)
        print("🔥 Guest table created successfully")
        
        // Avatar table - Shared avatar library
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS avatar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            avatarId TEXT,
            name TEXT,
            subtitle TEXT,
            characterOption TEXT,
            characterAction TEXT,
            characterLocation TEXT,
            profileImageName TEXT,
            profileImageURL TEXT,
            thumbnailURL TEXT,
            userId INTEGER NOT NULL,
            isPublic INTEGER NOT NULL DEFAULT 1,
            dateCreated TEXT,
            dateModified TEXT,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
            ) STRICT
            """
        ).execute(db)
        print("🔥 Avatar table created successfully")
        
        
        // Chat table - User-Avatar conversations
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS chat (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userID INTEGER NOT NULL,
            avatarID INTEGER NOT NULL,
            title TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (avatarID) REFERENCES avatar(id) ON DELETE CASCADE
            ) STRICT
            """
        ).execute(db)
        print("🔥 Chat table created successfully")
        
        // Message table - Individual chat messages
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS message (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chatID INTEGER NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isFromUser INTEGER NOT NULL,
            createdAt TEXT,
            FOREIGN KEY (chatID) REFERENCES chat(id) ON DELETE CASCADE
            ) STRICT
            """
        ).execute(db)
        print("🔥 Message table created successfully")
        
        // Tag table - Enhanced with category and color
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS tag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color TEXT,
            category TEXT,
            dateCreated TEXT,
            dateModified TEXT
            ) STRICT
            """
        ).execute(db)
        print("🔥 Tag table created successfully")
        
        // Badge table - Message achievements/metadata
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS badge (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT,
            color TEXT,
            description TEXT,
            dateCreated TEXT,
            dateModified TEXT
            ) STRICT
            """
        ).execute(db)
        print("🔥 Badge table created successfully")
        
        // MessageTag junction table
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS message_tag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            messageID INTEGER NOT NULL,
            tagID INTEGER NOT NULL,
            dateAdded TEXT,
            FOREIGN KEY (messageID) REFERENCES message(id) ON DELETE CASCADE,
            FOREIGN KEY (tagID) REFERENCES tag(id) ON DELETE CASCADE,
            UNIQUE(messageID, tagID)
            ) STRICT
            """
        ).execute(db)
        print("🔥 MessageTag junction table created successfully")
        
        // MessageBadge junction table
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS message_badge (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            messageID INTEGER NOT NULL,
            badgeID INTEGER NOT NULL,
            dateAdded TEXT,
            FOREIGN KEY (messageID) REFERENCES message(id) ON DELETE CASCADE,
            FOREIGN KEY (badgeID) REFERENCES badge(id) ON DELETE CASCADE,
            UNIQUE(messageID, badgeID)
            ) STRICT
            """
        ).execute(db)
        print("🔥 MessageBadge junction table created successfully")
        
        // Keep existing AvatarTag for backward compatibility
        try #sql(
            """
            CREATE TABLE IF NOT EXISTS avatarTag (
            avatarId INTEGER NOT NULL,
            tagId INTEGER NOT NULL,
            PRIMARY KEY (avatarId, tagId),
            FOREIGN KEY (avatarId) REFERENCES avatar(id) ON DELETE CASCADE,
            FOREIGN KEY (tagId) REFERENCES tag(id) ON DELETE CASCADE
            ) STRICT
            """
        ).execute(db)
        print("🔥 AvatarTag table created successfully")
    }


    #if DEBUG
    migrator.registerMigration("Seed Database") { db in
        print("🔥 Seeding DEBUG database with sample data for new entity model")
       
            try db.seed {
                // Users - Consolidated with auth and profile data
                User(
                    id: 1,
                    name: "Graham Hindle",
                    dateOfBirth: Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15)),
                    email: "graham@example.com",
                    dateCreated: Date(),
                    lastSignedInDate: Date(),
                    authId: "auth0|507f1f77bcf86cd799439011",
                    isAuthenticated: true,
                    providerID: "password",
                    membershipStatus: .premium,
                    authorizationStatus: .authorized,
                    themeColorHex: 0xFF5733_ff,
                    profileCreatedAt: Date(),
                    profileUpdatedAt: nil
                )
                User(
                    id: 2,
                    name: "Jane Doe",
                    dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 8, day: 22)),
                    email: "jane.doe@example.com",
                    dateCreated: Date().addingTimeInterval(-86400),
                    lastSignedInDate: Date().addingTimeInterval(-3600),
                    authId: "google-oauth2|123456789012345",
                    isAuthenticated: true,
                    providerID: "google-oauth2",
                    membershipStatus: .free,
                    authorizationStatus: .authorized,
                    themeColorHex: 0x4287f5_ff,
                    profileCreatedAt: Date().addingTimeInterval(-86400),
                    profileUpdatedAt: nil
                )
                User(
                    id: 3,
                    name: "Guest User",
                    dateOfBirth: nil,
                    email: nil,
                    dateCreated: Date().addingTimeInterval(-172800),
                    lastSignedInDate: nil,
                    authId: "guest|guest_user_temp",
                    isAuthenticated: false,
                    providerID: "guest",
                    membershipStatus: .free,
                    authorizationStatus: .guest,
                    themeColorHex: 0x28a745_ff,
                    profileCreatedAt: Date().addingTimeInterval(-172800),
                    profileUpdatedAt: nil
                )
                
                // Guest record for User 3
                Guest(
                    id: 1,
                    userID: 3,
                    sessionID: "guest_session_123",
                    expiresAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date(),
                    createdAt: Date()
                )
                
                
                // Avatars - Shared library
                Avatar(
                    id: 1,
                    avatarId: "avatar_professional",
                    name: "Sarah Professional",
                    subtitle: "Business consultant",
                    characterOption: .woman,
                    characterAction: .working,
                    characterLocation: .city,
                    profileImageName: "professional_avatar",
                    profileImageURL: "https://picsum.photos/200/300?random=1",
                    thumbnailURL: "https://picsum.photos/100/100?random=1",
                    userId: 1,
                    isPublic: true,
                    dateCreated: Date(),
                    dateModified: nil
                )
                Avatar(
                    id: 2,
                    avatarId: "avatar_creative",
                    name: "Alex Creative",
                    subtitle: "Digital artist",
                    characterOption: .man,
                    characterAction: .studying,
                    characterLocation: .museum,
                    profileImageName: "creative_avatar",
                    profileImageURL: "https://picsum.photos/200/300?random=2",
                    thumbnailURL: "https://picsum.photos/100/100?random=2",
                    userId: 1,
                    isPublic: true,
                    dateCreated: Date().addingTimeInterval(-3600),
                    dateModified: nil
                )
                Avatar(
                    id: 3,
                    avatarId: "avatar_casual",
                    name: "Chris Casual",
                    subtitle: "Friendly neighbor",
                    characterOption: .woman,
                    characterAction: .relaxing,
                    characterLocation: .park,
                    profileImageName: "casual_avatar",
                    profileImageURL: "https://picsum.photos/200/300?random=3",
                    thumbnailURL: "https://picsum.photos/100/100?random=3",
                    userId: 2,
                    isPublic: false,
                    dateCreated: Date().addingTimeInterval(-7200),
                    dateModified: nil
                )
                
                
                // Chats - User-Avatar conversations
                Chat(
                    id: 1,
                    userID: 1,
                    avatarID: 1,
                    title: "Business Strategy Discussion",
                    createdAt: Date().addingTimeInterval(-3600),
                    updatedAt: Date().addingTimeInterval(-1800)
                )
                Chat(
                    id: 2,
                    userID: 1,
                    avatarID: 2,
                    title: "Creative Project Ideas",
                    createdAt: Date().addingTimeInterval(-7200),
                    updatedAt: Date().addingTimeInterval(-3600)
                )
                Chat(
                    id: 3,
                    userID: 2,
                    avatarID: 1,
                    title: nil,
                    createdAt: Date().addingTimeInterval(-10800),
                    updatedAt: Date().addingTimeInterval(-9000)
                )
                
                // Messages
                Message(
                    id: 1,
                    chatID: 1,
                    content: "Hello Sarah! I'd like to discuss our business strategy for next quarter.",
                    timestamp: Date().addingTimeInterval(-3600),
                    isFromUser: true,
                    createdAt: Date().addingTimeInterval(-3600)
                )
                Message(
                    id: 2,
                    chatID: 1,
                    content: "Hi! I'd be happy to help with your strategy planning. What specific areas are you focusing on?",
                    timestamp: Date().addingTimeInterval(-3540),
                    isFromUser: false,
                    createdAt: Date().addingTimeInterval(-3540)
                )
                Message(
                    id: 3,
                    chatID: 2,
                    content: "I'm looking for some creative inspiration for my latest project.",
                    timestamp: Date().addingTimeInterval(-7200),
                    isFromUser: true,
                    createdAt: Date().addingTimeInterval(-7200)
                )
                
                // Tags - Enhanced with categories
                Tag(
                    id: 1,
                    name: "Business",
                    color: "#007AFF",
                    category: "Professional",
                    dateCreated: Date(),
                    dateModified: nil
                )
                Tag(
                    id: 2,
                    name: "Strategy",
                    color: "#34C759",
                    category: "Professional",
                    dateCreated: Date(),
                    dateModified: nil
                )
                Tag(
                    id: 3,
                    name: "Creative",
                    color: "#FF9500",
                    category: "Arts",
                    dateCreated: Date(),
                    dateModified: nil
                )
                Tag(
                    id: 4,
                    name: "Inspiration",
                    color: "#AF52DE",
                    category: "Arts",
                    dateCreated: Date(),
                    dateModified: nil
                )
                
                // Badges
                Badge(
                    id: 1,
                    name: "First Message",
                    icon: "star.fill",
                    color: "#FFD700",
                    description: "Sent your first message",
                    dateCreated: Date(),
                    dateModified: nil
                )
                Badge(
                    id: 2,
                    name: "Conversationalist",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: "#007AFF",
                    description: "Had a meaningful conversation",
                    dateCreated: Date(),
                    dateModified: nil
                )
                
                // MessageTag relationships
                MessageTag(
                    id: 1,
                    messageID: 1,
                    tagID: 1,
                    dateAdded: Date().addingTimeInterval(-3600)
                )
                MessageTag(
                    id: 2,
                    messageID: 2,
                    tagID: 2,
                    dateAdded: Date().addingTimeInterval(-3540)
                )
                MessageTag(
                    id: 3,
                    messageID: 3,
                    tagID: 3,
                    dateAdded: Date().addingTimeInterval(-7200)
                )
                
                // MessageBadge relationships
                MessageBadge(
                    id: 1,
                    messageID: 1,
                    badgeID: 1,
                    dateAdded: Date().addingTimeInterval(-3600)
                )
                
                // Keep existing AvatarTag for backward compatibility
                AvatarTag(avatarId: 1, tagId: 1)
                AvatarTag(avatarId: 2, tagId: 3)
                AvatarTag(avatarId: 3, tagId: 4)
            }

    }
    #endif


    try migrator.migrate(database)
    print("🔥 Database migration completed successfully \(database)")

    return database
}

//public final class DatabaseCoordinator: Sendable {
//    private let dbWriter: any DatabaseWriter
//
//    public init(dbWriter: any DatabaseWriter) throws {
//        self.dbWriter = dbWriter
//    }
//
//    public var writer: any DatabaseWriter {
//        dbWriter
//    }
//
//    public var reader: any DatabaseReader {
//        dbWriter
//    }
//}
//
//// MARK: - Dependency Injection
//
//extension DependencyValues {
//    public var appDatabaseContext: AppDatabaseContext {
//        get { self[AppDatabaseContextKey.self] }
//        set { self[AppDatabaseContextKey.self] = newValue }
//    }
//    
//    public var databases: [AppDatabaseContext: any DatabaseWriter] {
//        get { self[DatabasesKey.self] }
//        set { self[DatabasesKey.self] = newValue }
//    }
//}
//
//private struct AppDatabaseContextKey: DependencyKey {
//    static let liveValue: AppDatabaseContext = .live
//    static let testValue: AppDatabaseContext = .preview
//    static let previewValue: AppDatabaseContext = .preview
//    static let guestValue: AppDatabaseContext = .guest
//    static let mockValue: AppDatabaseContext = .mocks
//}
//
//private struct DatabasesKey: DependencyKey {
//    static let liveValue: [AppDatabaseContext: any DatabaseWriter] = [:]
//    static let testValue: [AppDatabaseContext: any DatabaseWriter] = [:]
//    static let previewValue: [AppDatabaseContext: any DatabaseWriter] = [:]
//}

public let logger = Logger(subsystem: "MyTCAApp", category: "Database")

