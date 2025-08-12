import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "TabBarFeature",
    dependencies: Constants.commonDependencies + [
        .project(target: "AvatarFeature", path: "../AvatarFeature"),
        .project(target: "Chat", path: "../Chat"),
        .project(target: "UserFeature", path: "../UserFeature"),
        .project(target: "UIComponents", path: "../UIComponents")
    ]
)

let project = Constants.createProject(config: config)
