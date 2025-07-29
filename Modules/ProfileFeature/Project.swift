import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "ProfileFeature",
    dependencies: [
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
        .external(name: "SharingGRDB")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Assets.xcassets")
    ]),
    testDependencies: [
        .external(name: "DependenciesTestSupport"),
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTestingCustomDump")
    ]
)

let project = Constants.createProject(config: config)
