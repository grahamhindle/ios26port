import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "Chat",
    dependencies: [
        .external(name: "ComposableArchitecture")
    ]
)

let project = Constants.createProject(config: config)
