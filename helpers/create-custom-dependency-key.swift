// Example of custom dependency key approach (for reference)
import SharingGRDB

// Create your own database dependency key
public struct AppDatabaseKey: DependencyKey {
    public static let liveValue: any DatabaseWriter = {
        do {
            return try appDatabase()
        } catch {
            fatalError("Failed to create live database: \(error)")
        }
    }()
    
    public static let testValue: any DatabaseWriter = {
        do {
            // Always in-memory for tests
            var config = Configuration()
            config.foreignKeysEnabled = true
            return try DatabaseQueue(configuration: config)
        } catch {
            fatalError("Failed to create test database: \(error)")
        }
    }()
    
    public static let previewValue: any DatabaseWriter = testValue
}

extension DependencyValues {
    public var appDatabase: any DatabaseWriter {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

// Then use it in ProfileModel:
// @Dependency(\.appDatabase) var database