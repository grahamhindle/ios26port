import ProjectDescription

let settings: SettingsDictionary = [:].otherSwiftFlags("-enable-actor-data-race-checks")


let project = Project(
    name: "SharedModels",
   
    targets: [
        // SharedModels Framework
        .target(
            name: "SharedModels", 
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.grahamhindle.SharedModels",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["SharedModels/**"],
            dependencies: [
                .external(name: "SharingGRDB"),
                .project(target: "SharedResources", path: "../SharedResources")
            ],
            settings: .settings(base: settings)
               
        ),
        
        // SharedModels Tests
        .target(
            name: "SharedModelsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.grahamhindle.SharedModelsTests",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .default,
            sources: ["SharedModelsTests/**"],
            dependencies: [
                .target(name: "SharedModels"),
                .external(name: "DependenciesTestSupport"),
                .external(name: "InlineSnapshotTesting"),
                .external(name: "SnapshotTestingCustomDump")
            ],
            
        )
    ]
)