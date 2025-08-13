import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DependencyAnalyzer",
    targets: [
        .target(
            name: "DependencyAnalyzer",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "\(Constants.bundleIdPrefix).dependencyanalyzer",
            deploymentTargets: .macOS("13.0"),
            sources: ["Sources/**"],
            dependencies: [],
            settings: .settings(base: Constants.baseSettings)
        )
    ],
    schemes: [
        .scheme(
            name: "DependencyAnalyzer",
            shared: true,
            buildAction: .buildAction(
                targets: [TargetReference(stringLiteral: "DependencyAnalyzer")]
            ),
            runAction: .runAction(executable: "DependencyAnalyzer")
        )
    ]
)
