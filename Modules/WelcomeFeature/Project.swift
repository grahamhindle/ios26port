import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "WelcomeFeature",
    dependencies: Constants.commonDependencies
)

let project = Constants.createProject(config: config)
