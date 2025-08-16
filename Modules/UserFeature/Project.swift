import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UserFeature",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "SharingGRDB"),
        .external(name: "Dependencies"),
        .project(target: "DatabaseModule", path: "../DatabaseModule"),
        .project(target: "AuthFeature", path: "../AuthFeature"),
        .project(target: "UIComponents", path: "../UIComponents")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/UserFeatureDemo.entitlements",
    demoDependencies: [
        .external(name: "Auth0")
    ]
)

let project = Constants.createProject(config: config)
