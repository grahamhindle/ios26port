import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "MainFeature",
    dependencies: [
        // Add your dependencies here
        // .external(name: "SomeDependency"),
        // .project(target: "SharedModels", path: "../SharedModels")
    ]
)

let project = Constants.createProject(config: config)
