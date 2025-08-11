import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UIComponents",
    dependencies: Constants.commonDependencies + Constants.databaseDependencies,
    sources: ["Sources/**"],
    resources: .resources([
        .glob(pattern: "Resources/**"),
    ])
)

let project = Constants.createProject(config: config)
