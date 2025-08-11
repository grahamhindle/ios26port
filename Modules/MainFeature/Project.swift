import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "MainFeature",
    dependencies: [
        // Add your dependencies here
        // .external(name: "SomeDependency"),
        // .project(target: "DatabaseModule", path: "../DatabaseModule")
    ]
)

let project = Constants.createProject(config: config)
