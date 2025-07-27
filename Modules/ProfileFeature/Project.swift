import ProjectDescription

let project = Project(
    name: "ProfileFeature",
    targets: [
        // Main ProfileFeature Framework
        .target(
            name: "ProfileFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.ProfileFeature",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["ProfileFeature/Sources/**"],
            dependencies: [
                .project(target: "SharedModels", path: "../SharedModels"),
                .external(name: "SharingGRDB"),
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

        // ProfileFeature Tests
        .target(
            name: "ProfileFeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.ProfileFeatureTests",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["ProfileFeature/Tests/**"],
            dependencies: [
                .target(name: "ProfileFeatureDemo"),
                .external(name: "DependenciesTestSupport"),
                .external(name: "InlineSnapshotTesting"),
                .external(name: "SnapshotTestingCustomDump")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "DEVELOPMENT_TEAM": "2W35ZL7A5C",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/ProfileFeatureDemo.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/ProfileFeatureDemo"
                ]
            )
        ),

        // Demo App
        .target(
            name: "ProfileFeatureDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.grahamhindle.ProfileFeatureDemo",
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
            sources: ["ProfileFeature/Demo/**"],
            resources: ["ProfileFeature/Demo/Assets.xcassets"],
            dependencies: [
                .target(name: "ProfileFeature"),
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
        )
    ],
    schemes: [
        .scheme(
            name: "ProfileFeature",
            shared: true,
            buildAction: .buildAction(targets: ["ProfileFeature", "ProfileFeatureDemo"]),
            testAction: .targets(["ProfileFeatureTests"])
        ),
        .scheme(
            name: "ProfileFeatureDemo",
            shared: true,
            buildAction: .buildAction(targets: ["ProfileFeatureDemo"]),
            //testAction: .targets(["ProfileFeatureTests"]),
            runAction: .runAction(executable: "ProfileFeatureDemo")
        )
    ]
)
