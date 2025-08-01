

import AuthFeature
import ComposableArchitecture
import SwiftUI
import SharedModels
import SharingGRDB
import UserFeature


@main
struct UserFeatureDemoApp: App {

    @Dependency(\.context) var context
    @Bindable static var userModel = UserModel(detailType: .all)

//    static let store = Store(initialState: AuthFeature.State()) {
//        AuthFeature()
//    }

      init() {
        if context == .live {
          prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
          }
        }
      }

    var body: some Scene {
        WindowGroup {
            if context == .live {
                   NavigationStack {

                       UserView(model: Self.userModel)

                   }
                 }

        }
    }
}


