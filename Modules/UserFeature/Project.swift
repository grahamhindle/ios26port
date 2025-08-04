import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UserFeature",
    dependencies: [
        .project(target: "SharedModels", path: "../SharedModels"),
        .project(target: "SharedResources", path: "../SharedResources"),
        .project(target: "AuthFeature", path: "../AuthFeature"),
        .external(name: "ComposableArchitecture"),
        .external(name: "Auth0"),
        .external(name: "SharingGRDB")
    ],
    resources: .resources([
        .glob(pattern: "../SharedResources/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/UserFeatureDemo.entitlements",
    demoDependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "Auth0")
    ]
)

let project = Constants.createProject(config: config)