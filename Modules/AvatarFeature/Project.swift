import ProjectDescription

let project = Project(
    name: "AvatarFeature",
    targets: [
        // Main ProfileFeature Framework
        .target(
            name: "AvatarFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.AvatarFeature",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "SharedModels", path: "../SharedModels"),
                .project(target: "UIComponents", path: "../UIComponents"),
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

        // AvatarFeature Tests
        .target(
            name: "AvatarFeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.AvatarFeatureTests",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "AvatarFeatureDemo"),
                .external(name: "DependenciesTestSupport"),
                .external(name: "InlineSnapshotTesting"),
                .external(name: "SnapshotTestingCustomDump")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "DEVELOPMENT_TEAM": "2W35ZL7A5C",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/AvatarFeatureDemo.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/AvatarFeatureDemo"
                ]
            )
        ),

        // Demo App
        .target(
            name: "AvatarFeatureDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.grahamhindle.AvatarFeatureDemo",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .extendingDefault(
                with: [
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [:],
                    ],
                    "UILaunchScreen": [:],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                ]
            ),
            sources: ["Demo/**"],
            resources: ["Demo/Assets.xcassets"],
            dependencies: [
                .target(name: "AvatarFeature"),
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    //"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
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
            name: "AvatarFeature",
            shared: true,
            buildAction: .buildAction(targets: ["AvatarFeature", "AvatarFeatureDemo"]),
            testAction: .targets(["AvatarFeatureTests"])
        ),
        .scheme(
            name: "Avatar   FeatureDemo",
            shared: true,
            buildAction: .buildAction(targets: ["AvatarFeatureDemo"]),
            
            runAction: .runAction(executable: "AvatarFeatureDemo")
        )
    ]
)