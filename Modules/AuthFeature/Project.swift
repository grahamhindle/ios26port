import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "AuthFeature",
    dependencies: Constants.commonDependencies + Constants.databaseDependencies + Constants.authDependencies + [
        .project(target: "UIComponents", path: "../UIComponents")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/AuthFeatureDemo.entitlements",
    testDependencies: [
        .external(name: "ComposableArchitecture")
    ],
    demoDependencies: Constants.authDependencies
)

let project = Constants.createProject(config: config)
