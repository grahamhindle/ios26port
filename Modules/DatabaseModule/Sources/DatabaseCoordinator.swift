// swiftlint:disable:next file_length
import OSLog
import SharingGRDB

public func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    print("🔥 appDatabase() called with context: \(context)")

    let configuration = createDatabaseConfiguration()
    let database = try createDatabase(configuration: configuration)
    let migrator = createMigrator()

    try migrator.migrate(database)
    print("🔥 Database migration completed successfully \(database)")

    return database
}

private func createDatabaseConfiguration() -> Configuration {
    @Dependency(\.context) var context
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { databaseData in
        #if DEBUG
            databaseData.trace(options: .profile) {
                if context == .preview {
                    print($0.expandedDescription)
                } else {
                    logger.debug("\($0.expandedDescription)")
                }
            }
        #endif
    }
    return configuration
}

private func createDatabase(configuration: Configuration) throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let database: any DatabaseWriter
    if context == .live {
        let path = URL.documentsDirectory.appending(component: "dbChat.sqlite").path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    } else if context == .test {
        let path = URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
        database = try DatabasePool(path: path, configuration: configuration)
    } else {
        database = try DatabaseQueue(configuration: configuration)
    }
    return database
}

private func createMigrator() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif

    registerInitialTablesMigration(&migrator)
    registerPromptColumnMigration(&migrator)
    registerPromptUpdateMigration(&migrator)

    #if DEBUG
        registerSeedDatabaseMigration(&migrator)
    #endif

    return migrator
}

private func registerInitialTablesMigration(_ migrator: inout DatabaseMigrator) {
    migrator.registerMigration("Create initial tables") { database in
        try createInitialTables(in: database)
    }
}

private func createInitialTables(in database: Database) throws {
    print("🔥 Creating tables for new entity model...")

    try createUsersTable(in: database)
    try createGuestTable(in: database)
    try createAvatarTable(in: database)
    try createChatTable(in: database)
    try createMessageTable(in: database)
    try createTagTable(in: database)
    try createBadgeTable(in: database)
    try createMessageTagTable(in: database)
    try createMessageBadgeTable(in: database)
    try createAvatarTagTable(in: database)
}

private func createUsersTable(in database: Database) throws {
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
        themeColorHex INTEGER NOT NULL DEFAULT \(raw: 0x4_4A99_EFFF),
        profileCreatedAt TEXT,
        profileUpdatedAt TEXT
        ) STRICT
        """
    ).execute(database)
    print("🔥 Users table created successfully")
}

private func createGuestTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 Guest table created successfully")
}

private func createAvatarTable(in database: Database) throws {
    try #sql(
        """
        CREATE TABLE IF NOT EXISTS avatar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        avatarId TEXT,
        name TEXT,
        subtitle TEXT,
        promptCategory TEXT,
        promptCharacterType TEXT,
        promptCharacterMood TEXT,
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
    ).execute(database)
    print("🔥 Avatar table created successfully")
}

private func createChatTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 Chat table created successfully")
}

private func createMessageTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 Message table created successfully")
}

private func createTagTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 Tag table created successfully")
}

private func createBadgeTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 Badge table created successfully")
}

private func createMessageTagTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 MessageTag junction table created successfully")
}

private func createMessageBadgeTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 MessageBadge junction table created successfully")
}

private func createAvatarTagTable(in database: Database) throws {
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
    ).execute(database)
    print("🔥 AvatarTag table created successfully")
}

private func registerPromptColumnMigration(_ migrator: inout DatabaseMigrator) {
    migrator.registerMigration("Add generatedPrompt to avatar table") { database in
        print("🔥 Adding generatedPrompt column to avatar table")
        try database.execute(sql: "ALTER TABLE avatar ADD COLUMN generatedPrompt TEXT")
        print("🔥 generatedPrompt column added successfully")
    }
}

private func registerPromptUpdateMigration(_ migrator: inout DatabaseMigrator) {
    migrator.registerMigration("Update existing avatars with sample prompts") { database in
        try updateExistingAvatarsWithPrompts(in: database)
    }
}

// swiftlint:disable:next function_body_length
private func updateExistingAvatarsWithPrompts(in database: Database) throws {
    print("🔥 Updating existing avatars with sample prompts")

    let businessPrompt = """
    You are an expert business consultant with a helpful personality, working from a city office.

    Please provide business insights and recommendations for:
    - Strategy
    - Analysis
    - Planning
    - Implementation

    **User Request**: Please help me with this business task
    **Context**: General business assistance needed
    **Code**: No code provided
    **Specific Requirements**: None specified

    Please provide a comprehensive response with:
    1. Clear explanations
    2. Code examples where applicable
    3. Best practices
    4. Step-by-step guidance if needed
    """

    try database.execute(
        sql: "UPDATE avatar SET generatedPrompt = ? WHERE id = 1",
        arguments: [businessPrompt]
    )

    let creativePrompt = """
    You are an expert mentor with a creative personality, working from a museum.

    Please help me with design including:
    - Principles
    - Best practices
    - Recommendations
    - Creative solutions

    **User Request**: Please help me with this creative task
    **Context**: General creative assistance needed
    **Code**: No code provided
    **Specific Requirements**: None specified

    Please provide a comprehensive response with:
    1. Clear explanations
    2. Code examples where applicable
    3. Best practices
    4. Step-by-step guidance if needed
    """

    try database.execute(
        sql: "UPDATE avatar SET generatedPrompt = ? WHERE id = 2",
        arguments: [creativePrompt]
    )

    let casualPrompt = """
    You are an expert enthusiast with a friendly personality, working from a park.

    Please help me with the following request.

    **User Request**: Please help me with this casual task
    **Context**: General assistance needed
    **Code**: No code provided
    **Specific Requirements**: None specified

    Please provide a comprehensive response with:
    1. Clear explanations
    2. Code examples where applicable
    3. Best practices
    4. Step-by-step guidance if needed
    """

    try database.execute(
        sql: "UPDATE avatar SET generatedPrompt = ? WHERE id = 3",
        arguments: [casualPrompt]
    )

    print("🔥 Existing avatars updated with sample prompts")
}

#if DEBUG
    private func registerSeedDatabaseMigration(_ migrator: inout DatabaseMigrator) {
        migrator.registerMigration("Seed Database") { database in
            print("🔥 Seeding DEBUG database with sample data for new entity model")
            do {
                try seedDatabase(in: database)
                print("🔥 Database seeded successfully with sample data")
            } catch {
                print("🔥 ERROR: Database seeding failed: \(error)")
                throw error
            }
        }
    }

    private func seedDatabase(in database: Database) throws {
        try seedUsers(in: database)
        try seedGuests(in: database)
        try seedAvatars(in: database)
    }

    private func seedUsers(in database: Database) throws {
        @Dependency(\.date) var date

        try database.seed {
            User(
                id: 1,
                name: "John Doe",
                dateOfBirth: date().addingTimeInterval(-86400 * 365 * 30),
                email: "john@example.com",
                dateCreated: date(),
                lastSignedInDate: date().addingTimeInterval(-900),
                authId: "auth0|686e9c718d2bc0b5367bf1bd",
                isAuthenticated: true,
                providerID: "password",
                membershipStatus: .free,
                authorizationStatus: .authorized,
                themeColorHex: 0xE74C_3CFF,
                profileCreatedAt: date(),
                profileUpdatedAt: nil
            )
            User(
                id: 2,
                name: "Jane Smith",
                dateOfBirth: date().addingTimeInterval(-86400 * 365 * 25),
                email: "jane@example.com",
                dateCreated: date().addingTimeInterval(-3600),
                lastSignedInDate: date().addingTimeInterval(-1800),
                authId: "google-oauth2|123456789012345",
                isAuthenticated: true,
                providerID: "google-oauth2",
                membershipStatus: .premium,
                authorizationStatus: .authorized,
                themeColorHex: 0x3498_DBFF,
                profileCreatedAt: date().addingTimeInterval(-3600),
                profileUpdatedAt: nil
            )
            User(
                id: 3,
                name: "Bob Wilson",
                dateOfBirth: nil,
                email: nil,
                dateCreated: date().addingTimeInterval(-7200),
                lastSignedInDate: nil,
                authId: "guest|guest_user_temp",
                isAuthenticated: false,
                providerID: "guest",
                membershipStatus: .free,
                authorizationStatus: .guest,
                themeColorHex: 0x95A5_A6FF,
                profileCreatedAt: date().addingTimeInterval(-7200),
                profileUpdatedAt: nil
            )
        }
    }

    private func seedGuests(in database: Database) throws {
        @Dependency(\.date) var date

        try database.seed {
            Guest(
                id: 1,
                userID: 3,
                sessionID: "guest_session_123",
                expiresAt: Calendar.current.date(byAdding: .hour, value: 24, to: date()) ?? date(),
                createdAt: date()
            )
        }
    }

    private func seedAvatars(in database: Database) throws {
        @Dependency(\.date) var date

        try database.seed {
            Avatar(
                id: 1,
                avatarId: "avatar_business_001",
                name: "Business Professional",
                subtitle: "Expert business consultant",
                promptCategory: .business,
                promptCharacterType: .consultant,
                promptCharacterMood: .professional,
                profileImageName: "avatar_business_man",
                profileImageURL: "https://picsum.photos/seed/business/400/400",
                thumbnailURL: "https://picsum.photos/seed/business-thumb/200/200",
                userId: 1,
                isPublic: true,
                dateCreated: date().addingTimeInterval(-86400),
                dateModified: date().addingTimeInterval(-3600)
            )
            Avatar(
                id: 2,
                avatarId: "avatar_creative_002",
                name: "Creative Mentor",
                subtitle: "Design and creativity expert",
                promptCategory: .design,
                promptCharacterType: .mentor,
                promptCharacterMood: .creative,
                profileImageName: "avatar_creative_woman",
                profileImageURL: "https://picsum.photos/seed/creative/400/400",
                thumbnailURL: "https://picsum.photos/seed/creative-thumb/200/200",
                userId: 2,
                isPublic: true,
                dateCreated: date().addingTimeInterval(-72000),
                dateModified: date().addingTimeInterval(-1800)
            )
            Avatar(
                id: 3,
                avatarId: "avatar_casual_003",
                name: "Friendly Helper",
                subtitle: "Your casual assistant",
                promptCategory: .general,
                promptCharacterType: .enthusiast,
                promptCharacterMood: .friendly,
                profileImageName: "avatar_casual_person",
                profileImageURL: "https://picsum.photos/seed/casual/400/400",
                thumbnailURL: "https://picsum.photos/seed/casual-thumb/200/200",
                userId: 1,
                isPublic: false,
                dateCreated: date().addingTimeInterval(-43200),
                dateModified: date().addingTimeInterval(-900)
            )
        }
    }

#endif

public let logger = Logger(subsystem: "MyTCAApp", category: "Database")
