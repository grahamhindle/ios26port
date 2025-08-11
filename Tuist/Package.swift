// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "SharingGRDB": .framework,
            "ComposableArchitecture": .framework,
            "Auth0": .framework,
            "StructuredQueriesGRDB": .framework,
            // Make shared dependencies dynamic to avoid duplicates
            "Dependencies": .framework,
            "IssueReporting": .framework,
            "CustomDump": .framework,
            "XCTestDynamicOverlay": .framework,
            "ConcurrencyExtras": .framework,
            "CombineSchedulers": .framework,
            "Clocks": .framework,
            // Additional shared dependencies
            "GRDB": .framework,
            "GRDBSQLite": .framework,
            "IdentifiedCollections": .framework,
            "InternalCollectionsUtilities": .framework,
            "OrderedCollections": .framework,
            "PerceptionCore": .framework,
            "Sharing": .framework,
            "Sharing1": .framework,
            "Sharing2": .framework,
            "StructuredQueriesCore": .framework,
            "StructuredQueriesGRDBCore": .framework,
            // Test dependencies
            "DependenciesTestSupport": .framework,
            "InlineSnapshotTesting": .framework,
            "SnapshotTestingCustomDump": .framework,
            "SnapshotTesting": .framework,
            "IssueReportingPackageSupport": .framework
        ]
    )
#endif

let package = Package(
    name: "ios26portPackages",
    platforms: [
        .iOS("26.0")
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.5"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.20.2"),
        .package(url: "https://github.com/auth0/Auth0.swift", from: "2.13.0")
    ]
)