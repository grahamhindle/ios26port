import ProjectDescription
import ProjectDescriptionHelpers

let config = ModuleConfig(
  name: "AppFeature",
  dependencies: [
   
    .project(target: "DatabaseModule", path: "../DatabaseModule"),
    .project(target: "UIComponents", path: "../UIComponents"),
    .project(target: "AuthFeature", path: "../AuthFeature"),
    .project(target: "WelcomeFeature", path: "../WelcomeFeature"),
    .project(target: "TabBarFeature", path: "../TabBarFeature"),
  ],
  testDependencies: [
    .external(name: "ComposableArchitecture")
  ],
  demoDependencies: []
)

let project = Constants.createProject(config: config)
