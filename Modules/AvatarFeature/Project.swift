import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AvatarFeature",
    dependencies: Constants.commonDependencies + [
        .external(name: "ComposableArchitecture"),
        .external(name: "SharingGRDB"),
        .external(name: "StructuredQueriesGRDB"),
        .project(target: "SharedModels", path: .relativeToRoot("Modules/SharedModels")),
        .project(target: "UIComponents", path: .relativeToRoot("Modules/UIComponents"))
    ]
)

let project = Constants.createProject(config:config)