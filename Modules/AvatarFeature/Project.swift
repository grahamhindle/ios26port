import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AvatarFeature",
            dependencies: [
            .external(name: "ComposableArchitecture"),
            .external(name: "ConcurrencyExtras"),
            .external(name: "Dependencies"),
            .project(target: "DatabaseModule", path: "../DatabaseModule")
        ] + [
        .project(target: "UIComponents", path: .relativeToRoot("Modules/UIComponents"))
    ]
)

let project = Constants.createProject(config: config)
