//
//  AuthInitView.swift
//  AuthFeature
//
//  Created by Graham Hindle on 24/07/2025.
//

import SharedModels
import SharingGRDB
import SwiftUI

import Charts




public struct AuthInitView: View {
    
    let model: AuthFeature
    public init(model: AuthFeature) {
        self.model = model
    }

    public var body: some View {

        List {

            ForEach(model.authorizedUsers) { authUser  in
            if let providerID = authUser.providerID {
                Text(providerID )
                
                }
            }

        }
    }
}

struct AuthInitPreviews: PreviewProvider {
    static var previews: some View {
        let _ = prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }

        Form {
        }
        .sheet(isPresented: .constant(true)) {
            // Provide a sample User for the preview
            NavigationStack {
                
                AuthInitView(model: AuthFeature())
            }
            .presentationDetents([.medium])
        }
    }
}
