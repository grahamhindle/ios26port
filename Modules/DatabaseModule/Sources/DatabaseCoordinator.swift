// swiftlint:disable:next file_length
import OSLog

@_exported import SharingGRDB


public func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
#if DEBUG
        db.trace(options: .profile) {
            if context == .live {
                logger.debug("\($0.expandedDescription)")
            } else {
                print("\($0.expandedDescription)")
            }
        }
#endif
    }
    if context == .preview {
        database = try DatabaseQueue(configuration: configuration)
    } else {
        let path = context == .live
        ? URL.documentsDirectory.appending(component: "db.sqlite").path()
        : URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
        print("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    }
    var migrator = DatabaseMigrator()
#if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
#endif
    migrator.registerMigration("Create initial tables") { db in
        try db.createUsersTable()
        try db.createGuestTable()
        try db.createAvatarTable()
        try db.createChatTable()
        try db.createMessageTable()
        try db.createTagTable()
        try db.createBadgeTable()
        try db.createMessageTagTable()
        try db.createMessageBadgeTable()
        try db.createAvatarTagTable()
    }

    try migrator.migrate(database)
    print("🔥 Database migration completed successfully \(database)")
    #if DEBUG
    try database.write { db in
            try db.seedSampleData()
    }
    #endif
    return database
}
public let logger = Logger(subsystem: "MyTCAApp", category: "Database")
