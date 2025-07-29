import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "SharedModels",
    dependencies: [
        .external(name: "SharingGRDB"),
        .project(target: "SharedResources", path: "../SharedResources")
    ],
    testDependencies: [
        .external(name: "DependenciesTestSupport"),
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTestingCustomDump")
    ],
    product: .staticFramework
)

let project = Constants.createProject(config: config)