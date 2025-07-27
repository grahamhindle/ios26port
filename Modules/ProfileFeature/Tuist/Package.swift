// swift-tools-version: 6.1
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
        // productTypes: [
        //     "SharingGRDB": .framework,
        //     "DependenciesTestSupport": .framework,
        //     "InlineSnapshotTesting": .framework,
        //     "SnapshotTestingCustomDump": .framework
        // ]
    )
#endif

let package = Package(
    name: "ios26portPackages",
    platforms: [
        .iOS(.v18)
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.5")
    ]
)