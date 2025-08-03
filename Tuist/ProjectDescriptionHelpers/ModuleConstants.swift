import ProjectDescription

// MARK: - Configuration

public struct ModuleConfig {
    public let name: String
    public let bundleId: String
    public let dependencies: [TargetDependency]
    public let sources: SourceFilesList
    public let resources: ResourceFileElements?
    public let entitlements: Path?
    public let infoPlist: [String: Plist.Value]?
    public let settings: SettingsDictionary?
    public let testDependencies: [TargetDependency]?
    public let demoDependencies: [TargetDependency]?
    public let product: Product

    public init(
        name: String,
        bundleId: String? = nil,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlements: Path? = nil,
        infoPlist: [String: Plist.Value]? = nil,
        settings: SettingsDictionary? = nil,
        testDependencies: [TargetDependency]? = nil,
        demoDependencies: [TargetDependency]? = nil,
        product: Product = .framework
    ) {
        self.name = name
        self.bundleId = bundleId ?? "\(Constants.bundleIdPrefix).\(name.lowercased())"
        self.dependencies = dependencies
        self.sources = sources
        self.resources = resources
        self.entitlements = entitlements
        self.infoPlist = infoPlist
        self.settings = settings
        self.testDependencies = testDependencies
        self.demoDependencies = demoDependencies
        self.product = product
    }
}

// MARK: - Constants

public enum Constants {
    public static let bundleIdPrefix = "com.grahamhindle"
    public static let developmentTeam = "2W35ZL7A5C"
    public static let iosVersion = "18.5"
    public static let swiftVersion = "6.1"
    public static let targetedDeviceFamily = "1,2"
    public static let author = "Graham Hindle"
    public static let organization = "grahamhindle"
    public static let demoBundleId = "com.grahamhindle.tcaapp"

    // MARK: - Settings

    public static let baseSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "minimal",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "ENABLE_MODULE_VERIFIER": "NO",
        "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
        "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
        "DEVELOPMENT_TEAM": SettingValue(stringLiteral: developmentTeam),
        "TARGETED_DEVICE_FAMILY": SettingValue(stringLiteral: targetedDeviceFamily),
    ]

    public static let demoSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "ENABLE_MODULE_VERIFIER": "NO",
        "CODE_SIGN_STYLE": "Automatic",
        "CODE_SIGN_IDENTITY": "Apple Development",
        "DEVELOPMENT_TEAM": SettingValue(stringLiteral: developmentTeam),
        "TARGETED_DEVICE_FAMILY": SettingValue(stringLiteral: targetedDeviceFamily),
    ]

    public static let testSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "minimal",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    ]

    // MARK: - InfoPlist

    public static let demoInfoPlist: [String: Plist.Value] = [
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [:],
        ],
        "UILaunchScreen": ["UIColorName": "AccentColor",
                           "UIImageName": "LaunchScreen"],
        "NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": true,
        ],
    ]

    // MARK: - Common Dependencies

    public static let commonDependencies: [TargetDependency] = [
        .external(name: "ComposableArchitecture"),
        .external(name: "SharingGRDB"),
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
    ]

    public static let authDependencies: [TargetDependency] = [
        .external(name: "Auth0"),
        .external(name: "SharingGRDB"),
    ]

    public static let testDependencies: [TargetDependency] = [
        .external(name: "DependenciesTestSupport"),
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTestingCustomDump"),
    ]
}

// MARK: - Target Builders

public extension Constants {
    static func frameworkTarget(
        name: String,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        settings: SettingsDictionary? = nil,
        product: Product = .framework
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: product,
            bundleId: "\(bundleIdPrefix).\(name.lowercased())",
            deploymentTargets: .iOS(iosVersion),
            sources: sources,
            dependencies: dependencies,
            settings: .settings(base: settings ?? baseSettings)
        )
    }

    static func testTarget(
        name: String,
        testedTargetName: String,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Tests/**"]
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleIdPrefix).\(name.lowercased())",
            deploymentTargets: .iOS(iosVersion),
            sources: sources,
            dependencies: [
                .target(name: testedTargetName),
            ] + dependencies,
            settings: .settings(base: testSettings)
        )
    }

    static func demoTarget(
        name: String,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Demo/**"],
        resources: ResourceFileElements? = [.glob(pattern: "../SharedResources/Resources/Assets.xcassets")],
        entitlements: Path? = nil,
        infoPlist: [String: Plist.Value]? = nil
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: demoBundleId,
            deploymentTargets: .iOS(iosVersion),
            infoPlist: .extendingDefault(with: infoPlist ?? demoInfoPlist),
            sources: sources,
            resources: resources,
            entitlements: entitlements.map { Entitlements.file(path: $0) },
            dependencies: dependencies,
            settings: .settings(base: demoSettings)
        )
    }
}

// MARK: - Project Builder

public extension Constants {
    static func createProject(
        config: ModuleConfig,
        schemes: [Scheme] = []
    ) -> Project {
        let frameworkTarget = frameworkTarget(
            name: config.name,
            dependencies: config.dependencies,
            sources: config.sources,
            settings: config.settings,
            product: config.product
        )

        let testTarget = testTarget(
            name: "\(config.name)Tests",
            testedTargetName: config.name,
            dependencies: config.testDependencies ?? testDependencies,
            sources: ["Tests/**"]
        )

        let demoTarget = demoTarget(
            name: "\(config.name)Demo",
            dependencies: [.target(name: config.name)] + (config.demoDependencies ?? []),
            sources: ["Demo/**"],
            resources: config.resources,
            entitlements: config.entitlements
        )

        let defaultSchemes: [Scheme] = [
            .scheme(
                name: config.name,
                shared: true,
                buildAction: .buildAction(targets: [TargetReference(stringLiteral: config.name), TargetReference(stringLiteral: "\(config.name)Demo")]),
                testAction: .targets(["\(config.name)Tests"])
            ),
            .scheme(
                name: "\(config.name)Demo",
                shared: true,
                buildAction: .buildAction(targets: [TargetReference(stringLiteral: "\(config.name)Demo")]),
                runAction: .runAction(executable: "\(config.name)Demo")
            ),
        ]

        return Project(
            name: config.name,
            targets: [frameworkTarget, testTarget, demoTarget],
            schemes: schemes.isEmpty ? defaultSchemes : schemes
        )
    }
}
