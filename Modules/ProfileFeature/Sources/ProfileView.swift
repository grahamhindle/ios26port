//
//  ProfileView.swift
//  DatabaseUser
//
//  Created by Graham Hindle on 16/07/2025.
// 1

import Charts
import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI

public struct ProfileView: View {
  let model: ProfileModel

  public init(model: ProfileModel) {
    self.model = model
  }

  public var body: some View {
    List {
      Section {
        ForEach(model.profiles, id: \.id) { profile in
          ProfileRow(profile: profile)
            .swipeActions(edge: .trailing) {
              Button(role: .destructive) {
                model.deleteButtonTapped(profile: profile)
              } label: {
                Label("Delete", systemImage: "trash")
              }
              .tint(.red)
              Button {
                model.editButtonTapped(profile: profile)
              } label: {
                Label("Edit", systemImage: "pencil")
              }
              .tint(.blue)
            }
        }

      } header: {
        Text("My Profiles")
          .font(.largeTitle)
          .bold()
          .foregroundStyle(.black)
          .textCase(nil)
      }

      Section {
        // Tag
      } header: {
        Text("Tags")
          .font(.largeTitle)
          .bold()
          .foregroundStyle(.black)
          .textCase(nil)
      }

      // .searchable(text: $model.searchText)
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            Button {
              //
            } label: {
              HStack {
                Image(systemName: "plus.circle.fill")
                Text("New Profile")
              }
              .bold()
              .font(.title3)
            }
            Spacer()
            Button {
              model.addProfileButtonTapped()
            } label: {
              Text("Add Profile")
                .font(.title3)
            }
          }

          // .sheet(item: $model.profileForm) { profile in
//          NavigationStack {
//              ProfileForm(profile: model.profile)
//              .navigationTitle("New Profile")
//          }
//          .presentationDetents([.large])
       }
      }
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase()
  }
  NavigationStack {
    ProfileView(model: ProfileModel())
  }
}
