import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UIComponents",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "SharingGRDB"),
        .project(target: "SharedResources", path: "../SharedResources"),
        .project(target: "SharedModels", path: "../SharedModels")
    ],
    sources: ["Sources/**"],
    resources: .resources([
        .glob(pattern: "Resources/**")
    ])
)

let project = Constants.createProject(config: config)
