import ProjectDescription

let project = Project(
    name: "UIComponents",
    targets: [
        .target(
            name: "UIComponents",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.ghchat.uicomponents",
            deploymentTargets: .iOS("18.5"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "SharingGRDB"),
                .project(target: "SharedResources", path: "../SharedResources"),
                .project(target: "SharedModels", path: "../SharedModels"),
               
            ]
        ),
        .target(
            name: "UIComponentsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.ghchat.uicomponents.tests",
            deploymentTargets: .iOS("18.5"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "UIComponents"),
            ]
        ),
        .target(
            name: "UIComponentsDemoApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.grahamhindle.ghchat.uicomponents.demoapp",
            deploymentTargets: .iOS("18.5"),
            sources: ["Demo/**"],
            dependencies: [
                .target(name: "UIComponents")
            ]
        ),
    ]
)
