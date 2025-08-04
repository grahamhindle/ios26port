import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "ios26port",
    projects: [
        "Modules/AuthFeature",
        "Modules/AvatarFeature",
        "Modules/MainFeature",
        "Modules/SharedResources",
        "Modules/SharedModels",
        "Modules/UIComponents",
        "Modules/UserFeature"
    ]
)
