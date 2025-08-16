import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UIComponents",
    dependencies: [
        .project(target: "SharedResources", path: "../SharedResources"),
        .project(target: "DatabaseModule", path: "../DatabaseModule")
    ],
    sources: ["Sources/**"],
    resources: .resources([
        .glob(pattern: "Resources/**")
    ])
)

let project = Constants.createProject(config: config)
