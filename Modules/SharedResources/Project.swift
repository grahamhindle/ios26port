import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "SharedResources",
    sources: [
        "Sources/**",
        "Sources/**/*.swift",
    ]
)

let project = Constants.createProject(config: config)
