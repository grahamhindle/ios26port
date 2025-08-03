import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AvatarFeature",
    dependencies: [
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "UIComponents", path: "../UIComponents"),
        .external(name: "SharingGRDB")
    ],
    resources: .resources([
        .glob(pattern: "../SharedResources/Resources/Assets.xcassets")
    ])
)

let project = Constants.createProject(config: config)