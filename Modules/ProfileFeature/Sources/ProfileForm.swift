import SharedModels
import SharedResources
import SharingGRDB
import SwiftUI

public struct ProfileForm: View {
    @State var profile: Profile.Draft

    public init(profile: Profile.Draft){
        self.profile = profile
    }
//    public init(profile: Profile.Draft){
//        self.profile = profile
//    }
    @Dependency(\.defaultDatabase) var database
    @Environment(\.dismiss) var dismiss
  public var body: some View {
    Form {
      Section {
        VStack {

            Picker("Membership Status", selection: $profile.membershipStatus) {
                ForEach(MembershipStatus.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized)
                }
            }.pickerStyle(.segmented)
            .font(.system(.title2, design: .rounded, weight: .bold))
            //.foregroundStyle(Color(hex: profile.themeColorHex))
            //.multilineTextAlignment(.center)
            .padding()
            .textFieldStyle(.plain)

            Picker("Authorization Status", selection: $profile.authorizationStatus) {
                ForEach(AuthorizationStatus.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized)
                }
            }.pickerStyle(.segmented)
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundStyle(Color(hex: profile.themeColorHex))
            //.multilineTextAlignment(.center)
            .padding()
            .textFieldStyle(.plain)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.buttonBorder)
      }
        ColorPicker("Theme", selection: $profile.themeColorHex.swiftUIColor)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem {
        Button("Save") {
            withErrorReporting {
                try database.write { db in
                    try Profile.upsert { profile }
                        .execute(db)
                }
            }
            dismiss()
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
         dismiss()
        }
      }
    }
  }
}



struct ProfileFormPreviews: PreviewProvider {
    static var previews: some View {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
  Form {
  }
  .sheet(isPresented: .constant(true)) {
      NavigationStack {
          ProfileForm (profile: Profile.Draft(
            membershipStatus: .free,
            authorizationStatus: .guest,
            themeColorHex: 0x007A_FFFF
          ))
      }
      .presentationDetents([.medium])
  }
  }
}
