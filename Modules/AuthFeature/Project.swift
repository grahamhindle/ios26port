import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AuthFeature",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "Auth0"),
        .project(target: "DatabaseModule", path: "../DatabaseModule")
    ] + [
        .project(target: "UIComponents", path: "../UIComponents")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/AuthFeatureDemo.entitlements",
    testDependencies: [
        .external(name: "ComposableArchitecture")
    ],
    demoDependencies: [
        .external(name: "Auth0")
    ]
)

let project = Constants.createProject(config: config)
