import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
    name: "UserFeature",
    dependencies: Constants.commonDependencies + Constants.databaseDependencies + Constants.authDependencies + [
        .project(target: "AuthFeature", path: "../AuthFeature")
    ],
    resources: .resources([
        .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
    ]),
    entitlements: "Demo/Resources/UserFeatureDemo.entitlements",
    demoDependencies: Constants.authDependencies
)

let project = Constants.createProject(config: config)
