import ProjectDescription

let project = Project(
    name: "SharedResources",
    targets: [
        .target(
            name: "SharedResources",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.grahamhindle.mytcaapp.sharedresources",
            deploymentTargets: .iOS("18.5"),
            sources: [
                "Sources/**",
                "Sources/**/*.swift"
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.1",
                    "SWIFT_STRICT_CONCURRENCY": "minimal",
                    "USER_SCRIPT_SANDBOXING": "YES"
                ]
            )
        )
    ]
)
