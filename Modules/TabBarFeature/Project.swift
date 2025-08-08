import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "TabBarFeature",
    dependencies: Constants.commonDependencies + [
        .project(target: "Explore", path: "../Explore"),
        .project(target: "Chat", path: "../Chat"),
        .project(target: "UserFeature", path: "../UserFeature")
    ]
)

let project = Constants.createProject(config: config)
