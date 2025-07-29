import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AppFeature",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
        .project(target: "UIComponents", path: "../UIComponents"),
        .project(target: "AuthFeature", path: "../AuthFeature"),
        .external(name: "SharingGRDB")
    ],
    testDependencies: [
        .external(name: "ComposableArchitecture")

    ],
    demoDependencies: [
        .project(target: "AuthFeature", path: "../AuthFeature")
        .external(name: "ComposableArchitecture")
    ]
)

let project = Constants.createProject(config: config)
