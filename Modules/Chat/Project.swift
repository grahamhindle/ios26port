import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "Chat",
    dependencies: Constants.commonDependencies
)

let project = Constants.createProject(config: config)
