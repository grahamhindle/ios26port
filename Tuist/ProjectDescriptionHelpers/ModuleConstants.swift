import ProjectDescription

public enum ModuleConstants {
    public static let bundleIdPrefix = "com.grahamhindle"
    public static let developmentTeam = "2W35ZL7A5C"
    public static let iosVersion = "18.0"
    public static let swiftVersion = "6.2"
    public static let targetedDeviceFamily = "1,2"
    public static let author = "Graham Hindle"
    public static let organization = "grahamhindle"
    
    public static let baseSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
        "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
        "DEVELOPMENT_TEAM": SettingValue(stringLiteral: developmentTeam),
        "TARGETED_DEVICE_FAMILY": SettingValue(stringLiteral: targetedDeviceFamily)
    ]
    
    public static func frameworkTarget(
        name: String,
        sources: SourceFilesList = ["Sources/**"],
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .framework,
            bundleId: "\(bundleIdPrefix).\(name)",
            deploymentTargets: .iOS(iosVersion),
            sources: sources,
            dependencies: dependencies,
            settings: .settings(base: baseSettings)
        )
    }
    
    public static func testTarget(
        name: String,
        testedTargetName: String,
        sources: SourceFilesList = ["Tests/**"]
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleIdPrefix).\(name)",
            deploymentTargets: .iOS(iosVersion),
            sources: sources,
            dependencies: [
                .target(name: testedTargetName)
            ],
            settings: .settings(base: baseSettings)
        )
    }
    
    public static func appTarget(
        name: String,
        sources: SourceFilesList = ["Demo/**"],
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: "\(bundleIdPrefix).\(name)",
            deploymentTargets: .iOS(iosVersion),
            sources: sources,
            dependencies: dependencies,
            settings: .settings(base: baseSettings)
        )
    }
}