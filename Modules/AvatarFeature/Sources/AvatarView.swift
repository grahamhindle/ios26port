import SwiftUI
import SharedModels
import SharingGRDB
//import UIComponents

public struct AvatarView: View {
    let model: AvatarModel
    public init() {
        self.model = AvatarModel()
    }
    
    public var body: some View {
        List {
            Section {
                // Top-level stats
            }
            
            ForEach(model.avatars) { avatar in
                        AvatarRow(avatar:  avatar)
                    }
                    .onDelete { indexSet in
                     model.deleteButtonTapped(at: indexSet)
                    }

            
            Section {
                // Character options
            } header: {
                Text("My Avatars")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
        }
        .searchable(text: .constant(""))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        // New Avatar action
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Avatar")
                        }
                        .bold()
                        .font(.title3)
                    }
                    Spacer()
                    Button {
                        // Add Avatar action
                    } label: {
                        Text("Add Avatar")
                            .font(.title3)
                    }
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
        AvatarView()
    }
}
