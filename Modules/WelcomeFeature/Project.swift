import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "WelcomeFeature",
            dependencies: [
            .external(name: "ComposableArchitecture"),
            .external(name: "ConcurrencyExtras")
        ] + [
        .project(target: "AuthFeature", path: "../AuthFeature")
    ]
)

let project = Constants.createProject(config: config)
