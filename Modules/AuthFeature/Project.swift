import ProjectDescription

let project = Project(
    name: "AuthFeature",
    targets: [
        .target(
            name: "AuthFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.tcaapp",
            deploymentTargets: .iOS("18.5"),
            sources: ["Sources/**"],
            dependencies: [
               
               
                .external(name: "Auth0"),
                .project(target: "SharedModels", path: "../SharedModels"),
                .project(target: "SharedResources", path: "../SharedResources"),
                .project(target: "UIComponents", path: "../UIComponents"),
                .external(name: "SharingGRDB"),
                .external(name: "StructuredQueriesGRDB")

            ],
            settings: .settings(
               base: [
                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "NO",
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
                    "DEVELOPMENT_TEAM": "2W35ZL7A5C",
                    "DYLIB_INSTALL_NAME_BASE": "@rpath",
                    "ENABLE_MODULE_VERIFIER": "YES",
                    "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
                    "SKIP_INSTALL": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "ENABLE_PREVIEWS": "YES",
                ]
            )
        ),

        .target(
            name: "AuthFeatureDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.grahamhindle.tcaapp.demo",
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
            sources: ["Demo/**"],
            resources: .resources([
                .glob(pattern: "Demo/Resources/**", excluding: ["**/*.entitlements"])
            ]),
            entitlements: "Demo/Resources/AuthFeatureDemo.entitlements",
            dependencies: [
                .target(name: "AuthFeature"),
               
                .external(name: "Auth0"),
                .external(name: "SharingGRDB")

            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
                    "DEVELOPMENT_TEAM": "2W35ZL7A5C",
                    "ENABLE_PREVIEWS": "YES",
                    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                ]
            )
        ),

        .target(
            name: "AuthFeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.mytcaapp.authfeature.tests",
            deploymentTargets: .iOS("18.5"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "AuthFeature"),
                .external(name: "Auth0"),
                .external(name: "SharingGRDB")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "DEVELOPMENT_TEAM": "2W35ZL7A5C",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/UserFeatureDemo.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/UserFeatureDemo"
                ]
            )
        )
    ],
    schemes: [
        .scheme(
            name: "AuthFeature",
            shared: true,
            buildAction: .buildAction(targets: ["AuthFeature", "AuthFeatureDemo"]),
            testAction: .targets(["AuthFeatureTests"])
        ),
        .scheme(
            name: "AuthFeatureDemo",
            shared: true,
            buildAction: .buildAction(targets: ["AuthFeatureDemo"]),
            runAction: .runAction(executable: "AuthFeatureDemo")
        )
    ]
)
