// swift-tools-version: 6.1
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "SharingGRDB": .framework,
            "DependenciesTestSupport": .framework,
            "InlineSnapshotTesting": .framework,
            "SnapshotTestingCustomDump": .framework,
            "Auth0": .framework,
            "ComposableArchitecture": .framework,
            "StructuredQueriesGRDB": .framework
        ]

    )
#endif

let package = Package(
    name: "ios26portPackages",
    platforms: [
        .iOS("18.5")
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.5"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.20.2"),
        .package(url: "https://github.com/auth0/Auth0.swift", from: "2.13.0")
    ]
)