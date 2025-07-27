import ProjectDescription
let settings: SettingsDictionary = [:].otherSwiftFlags("-enable-actor-data-race-checks")

let project = Project(
    name: "UserFeature",
    targets: [
        // Main UserFeature Framework
        .target(
            name: "UserFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.UserFeature",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["UserFeature/Sources/**"],
            dependencies: [
                .project(target: "SharedModels", path: "../SharedModels"),
                .project(target: "SharedResources", path: "../SharedResources"),
                
               
            ],
            settings: .settings(base: settings)
           
        ),

        // UserFeature Tests
        .target(
            name: "UserFeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.UserFeatureTests",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["UserFeature/Tests/**"],
            dependencies: [
                .target(name: "UserFeatureDemo"),
                .external(name: "DependenciesTestSupport"),
                .external(name: "InlineSnapshotTesting"),
                .external(name: "SnapshotTestingCustomDump")
            ],
            // settings: .settings(
            //     base: [
            //         "SWIFT_VERSION": "6.1",
            //         "SWIFT_STRICT_CONCURRENCY": "complete",
            //         "DEVELOPMENT_TEAM": "2W35ZL7A5C",
            //         "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/UserFeatureDemo.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/UserFeatureDemo"
            //     ]
            // )
        ),

        // Demo App
        .target(
            name: "UserFeatureDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.grahamhindle.UserFeatureDemo",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .extendingDefault(
                with: [
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [:],
                    ],
                    "UILaunchScreen": [:],
                ]
            ),
            sources: ["UserFeature/Demo/**"],
            resources: ["UserFeature/Demo/Assets.xcassets"],
            dependencies: [
                .target(name: "UserFeature")
                
            ]
            
        )
    ],
    schemes: [
        .scheme(
            name: "UserFeature",
            shared: true,
            buildAction: .buildAction(targets: ["UserFeature", "UserFeatureDemo"]),
            testAction: .targets(["UserFeatureTests"])
        ),
        .scheme(
            name: "UserFeatureDemo",
            shared: true,
            buildAction: .buildAction(targets: ["UserFeatureDemo"]),
            runAction: .runAction(executable: "UserFeatureDemo")
        )
    ]
)