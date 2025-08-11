import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AvatarFeature",
    dependencies: Constants.commonDependencies + Constants.databaseDependencies + [
        .project(target: "UIComponents", path: .relativeToRoot("Modules/UIComponents")),
    ]
)

let project = Constants.createProject(config: config)
