import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "WelcomeFeature",
    dependencies: Constants.commonDependencies + [
        .project(target: "AuthFeature", path: "../AuthFeature")
    ]
)

let project = Constants.createProject(config: config)
