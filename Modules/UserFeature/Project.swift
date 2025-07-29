import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UserFeature",
    dependencies: [
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
        .project(target: "AuthFeature", path: "../AuthFeature"),
        .external(name: "ComposableArchitecture"),
        .external(name: "Auth0"),
        .external(name: "SharingGRDB")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/UserFeatureDemo.entitlements",
    testDependencies: [
        .external(name: "DependenciesTestSupport"),
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTestingCustomDump")
    ],
    demoDependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "Auth0")
    ]
)

let project = Constants.createProject(config: config)