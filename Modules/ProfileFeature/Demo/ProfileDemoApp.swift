import SwiftUI

import SharedModels
import ProfileFeature
import SharingGRDB




@main
struct ProfileFeatureDemoApp: App {

      @Dependency(\.context) var context
      static let model = ProfileModel()

      init() {
          if context == .live  {
          prepareDependencies { (dependencies: inout DependencyValues) in
              dependencies.defaultDatabase = try! SharedModels.appDatabase()

          }
        }
      }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ProfileView(model: ProfileModel())
            }
        }
    }
}

