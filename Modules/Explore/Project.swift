import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "Explore",
    dependencies: Constants.commonDependencies
)

let project = Constants.createProject(config: config)
