import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "DatabaseModule",
    dependencies: [
        .external(name: "SharingGRDB"),
        .project(target: "SharedResources", path: "../SharedResources")
    ],
    testDependencies: [
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTestingCustomDump")
    ],
    product: .framework
)

let project = Constants.createProject(config: config)