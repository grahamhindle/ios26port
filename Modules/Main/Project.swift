import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Main",
    targets: [
        ModuleConstants.frameworkTarget(
            name: "Main",
            dependencies: [
                // Add your dependencies here
                // .external(name: "SomeDependency"),
                // .project(target: "SharedModels", path: "../SharedModels")
            ]
        ),
        ModuleConstants.testTarget(
            name: "MainTests",
            testedTargetName: "Main"
        ),
        ModuleConstants.appTarget(
            name: "MainDemo",
            dependencies: [
                TargetDependency.target(name: "Main")
            ]
        )
    ]
)
