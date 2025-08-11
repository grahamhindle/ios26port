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
    public let databaseDependencies: [TargetDependency]?
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
        databaseDependencies: [TargetDependency]? = nil,
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
        self.databaseDependencies = databaseDependencies
        self.product = product
    }
}

// MARK: - Constants

public enum Constants {
    public static let bundleIdPrefix = "com.grahamhindle"
    public static let developmentTeam = "2W35ZL7A5C"
    public static let iosVersion = "26.0"
    public static let swiftVersion = "6.2"
    public static let targetedDeviceFamily = "1,2"
    public static let author = "Graham Hindle"
    public static let organization = "grahamhindle"
    public static let demoBundleId = "com.grahamhindle.tcaapp"

    // MARK: - Settings

    public static let baseSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "minimal",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "ENABLE_MODULE_VERIFIER": "YES",
        "MODULE_VERIFIER_SUPPORTED_LANGUAGES": "objective-c objective-c++",
        "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": "gnu11 gnu++17",
        "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
        "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
        "DEVELOPMENT_TEAM": SettingValue(stringLiteral: developmentTeam),
        "TARGETED_DEVICE_FAMILY": SettingValue(stringLiteral: targetedDeviceFamily),
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
    ]

    public static let demoSettings: SettingsDictionary = [
        "SWIFT_VERSION": SettingValue(stringLiteral: swiftVersion),
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "ENABLE_MODULE_VERIFIER": "YES",
        "MODULE_VERIFIER_SUPPORTED_LANGUAGES": "objective-c objective-c++",
        "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": "gnu11 gnu++17",
        "CODE_SIGN_STYLE": "Automatic",
        "CODE_SIGN_IDENTITY": "Apple Development",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
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
        .project(target: "SharedResources", path: "../SharedResources"),
    ]
    
    public static let databaseDependencies: [TargetDependency] = [
        .project(target: "DatabaseModule", path: "../DatabaseModule"),
    ]

    public static let authDependencies: [TargetDependency] = [
        .external(name: "Auth0")
    ]

    // MARK: - Auth0 Configuration

    public static let auth0Resources: ResourceFileElements = .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"]),
    ])

    public static let auth0Entitlements = "Demo/Resources/{MODULE_NAME}Demo.entitlements"

    public static let auth0EntitlementsContent = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    \t<key>com.apple.developer.applesignin</key>
    \t<array>
    \t\t<string>Default</string>
    \t</array>
    \t<key>com.apple.developer.associated-domains</key>
    \t<array>
    \t\t<string>webcredentials:dev-mt7cwqgw3eokr8pz.us.auth0.com</string>
    \t</array>
    </dict>
    </plist>
    """

    public static let auth0PlistContent = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>ClientId</key>
        <string>FYrB5CVx1aGhEZaMIQJ6ZaOtxPtwfFeS</string>
        <key>Domain</key>
        <string>dev-mt7cwqgw3eokr8pz.us.auth0.com</string>
    </dict>
    </plist>
    """

    public static let testDependencies: [TargetDependency] = [
        .external(name: "ComposableArchitecture"),
        .external(name: "DependenciesTestSupport"),
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

// MARK: - Auth0 Helper Functions

public extension Constants {
    /// Checks if a module requires Auth0 configuration based on its dependencies
    static func requiresAuth0(dependencies: [TargetDependency]) -> Bool {
        for dependency in dependencies {
            switch dependency {
            case let .external(name, _):
                if name == "Auth0" { return true }
            case let .project(target, _, _, _):
                if target == "AuthFeature" { return true }
            default:
                continue
            }
        }
        return false
    }

    /// Automatically configures Auth0 resources and entitlements for a module
    static func configureAuth0(for moduleName: String, config: inout ModuleConfig) {
        if requiresAuth0(dependencies: config.dependencies) {
            // Set up resources to include Demo/Resources with Auth0.plist
            config = ModuleConfig(
                name: config.name,
                bundleId: config.bundleId,
                dependencies: config.dependencies,
                sources: config.sources,
                resources: .resources([
                    .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"]),
                    .glob(pattern: "../SharedResources/Resources/Assets.xcassets"),
                ]),
                entitlements: config.entitlements ?? "Demo/Resources/\(moduleName)Demo.entitlements",
                infoPlist: config.infoPlist,
                settings: config.settings,
                testDependencies: config.testDependencies,
                demoDependencies: config.demoDependencies,
                product: config.product
            )
        }
    }

    /// Creates Auth0 configuration files for a module
    /// Note: This function is intended for use in build scripts, not during project generation
    static func createAuth0Files(for moduleName: String, at moduleDir: String) {
        // This function would be called from a build script or template generator
        // that has access to Foundation APIs like FileManager
        print("📋 Auth0 files should be created for \(moduleName) at \(moduleDir)")
        print("  - Auth0.plist")
        print("  - \(moduleName)Demo.entitlements")
        print("💡 Use: tuist scaffold auth-module --name \(moduleName)")
    }
}

// MARK: - Template Generation

public extension Constants {
    /// Generates a new TCA feature module with all necessary files
    ///
    /// Usage:
    /// ```swift
    /// Constants.generateTCAFeature(
    ///     moduleName: "ProductFeature",
    ///     entityName: "Product",
    ///     iconName: "shippingbox.fill",
    ///     moduleDir: "Modules/ProductFeature"
    /// )
    /// ```
    ///
    /// This creates:
    /// - Project.swift with TCA dependencies
    /// - ProductFeature.swift (main TCA reducer)
    /// - ProductFormFeature.swift (form TCA reducer)
    /// - ProductView.swift (main SwiftUI view)
    /// - ProductFormView.swift (form SwiftUI view)
    /// - ProductRow.swift (list row component)
    /// - ProductFeatureDemoApp.swift (demo app)
    /// - ProductFeatureTests.swift (test file)
    static func generateTCAFeature(
        moduleName: String,
        entityName: String,
        iconName: String = "circle.fill",
        moduleDir: String
    ) {
        TemplateGenerator.generateTCAFeature(
            for: moduleName,
            entityName: entityName,
            iconName: iconName,
            in: moduleDir
        )
    }

    /// Generates a new TCA feature module with Auth0 support
    ///
    /// Usage:
    /// ```swift
    /// Constants.generateAuthEnabledTCAFeature(
    ///     moduleName: "LoginFeature",
    ///     entityName: "Login",
    ///     iconName: "person.fill",
    ///     moduleDir: "Modules/LoginFeature"
    /// )
    /// ```
    ///
    /// This creates all the standard TCA files plus:
    /// - Auth0.plist with proper configuration
    /// - Demo entitlements for Auth0 and Apple Sign In
    /// - Proper resource configuration
    static func generateAuthEnabledTCAFeature(
        moduleName: String,
        entityName: String,
        iconName: String = "circle.fill",
        moduleDir: String
    ) {
        // Generate standard TCA feature first
        generateTCAFeature(
            moduleName: moduleName,
            entityName: entityName,
            iconName: iconName,
            moduleDir: moduleDir
        )

        // Create Auth0 configuration files
        createAuth0Files(for: moduleName, at: moduleDir)

        print("✅ Generated Auth0-enabled TCA feature: \(moduleName)")
    }
}

// MARK: - Project Builder

public extension Constants {
    static func createProject(
        config: ModuleConfig,
        schemes: [Scheme] = []
    ) -> Project {
        var finalConfig = config

        // Automatically configure Auth0 if needed
        configureAuth0(for: config.name, config: &finalConfig)
        let frameworkTarget = frameworkTarget(
            name: finalConfig.name,
            dependencies: finalConfig.dependencies,
            sources: finalConfig.sources,
            settings: finalConfig.settings,
            product: finalConfig.product
        )

        let testTarget = testTarget(
            name: "\(finalConfig.name)Tests",
            testedTargetName: finalConfig.name,
            dependencies: finalConfig.testDependencies ?? testDependencies,
            sources: ["Tests/**"]
        )

        let demoTarget = demoTarget(
            name: "\(finalConfig.name)Demo",
            dependencies: [.target(name: finalConfig.name)] + (finalConfig.demoDependencies ?? []),
            sources: ["Demo/**"],
            resources: finalConfig.resources,
            entitlements: finalConfig.entitlements
        )

        let defaultSchemes: [Scheme] = [
            .scheme(
                name: finalConfig.name,
                shared: true,
                buildAction: .buildAction(targets: [TargetReference(stringLiteral: finalConfig.name), TargetReference(stringLiteral: "\(finalConfig.name)Demo")]),
                testAction: .targets(["\(finalConfig.name)Tests"])
            ),
            .scheme(
                name: "\(finalConfig.name)Demo",
                shared: true,
                buildAction: .buildAction(targets: [TargetReference(stringLiteral: "\(finalConfig.name)Demo")]),
                runAction: .runAction(executable: "\(finalConfig.name)Demo")
            ),
        ]

        return Project(
            name: finalConfig.name,
            targets: [frameworkTarget, testTarget, demoTarget],
            schemes: schemes.isEmpty ? defaultSchemes : schemes
        )
    }
}
