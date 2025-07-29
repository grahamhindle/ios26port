import OSLog
import SharedModels
import SharingGRDB
import SwiftUI

//@Observable
//public final class ProfileDetailModel {
//    @ObservationIgnored
//    @Dependency(\.defaultDatabase) private var database
//    
//    public let profile: Profile
//
//
//    @ObservationIgnored
//    @FetchAll var avatars: [Avatar]
//    
//    // public init(profile: Profile) {
//    //     self.profile = profile
//    //     _avatars = FetchAll(
//    //         Avatar
//    //             .joining(required: ProfileAvatar.filter(Column("profileID") == profile.id))
//    //             .order(ProfileAvatar.Columns.isPrimary.desc, ProfileAvatar.Columns.dateAdded.asc)
//    //     )
//    // }
//    
//    public func addAvatar(_ avatar: Avatar) {
//        withErrorReporting {
//            try database.write { db in
//                try ProfileAvatar(
//                    profileID: profile.id,
//                    avatarID: avatar.id,
//                    isPrimary: avatars.isEmpty
//                ).insert(db)
//            }
//        }
//    }
//    
//    public func removeAvatar(_ avatar: Avatar) {
//        withErrorReporting {
//            try database.write { db in
//                try ProfileAvatar
//                    .filter(Column("profileID") == profile.id && Column("avatarID") == avatar.id)
//                    .deleteAll(db)
//            }
//        }
//    }
//}

//public struct ProfileDetailView: View {
//
//
//    public init() {
//
//    }
//    
//    public var body: some View {
//        List {
//            Section {
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Image(systemName: "person.circle.fill")
//                            .font(.title)
//                            .foregroundStyle(Color(hex: model.profiles.themeColorHex))
//                        VStack(alignment: .leading) {
//                            Text(profile.fullName)
//                                .font(.title2)
//                                .bold()
//                            Text(profile.email)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                    }
//                }
//                .padding(.vertical, 8)
//            } header: {
//                Text("Profile Information")
//                    .font(.headline)
//                    .textCase(nil)
//            }
//            
////            Section {
////                ForEach(model.avatars, id: \.id) { avatar in
////                    HStack {
////                        Image(systemName: "person.crop.circle")
////                            .font(.title2)
////                            .foregroundStyle(Color(hex: model.profile.themeColorHex))
////                        VStack(alignment: .leading, spacing: 4) {
////                            Text(avatar.name ?? "Unnamed Avatar")
////                                .font(.headline)
////                            if let subtitle = avatar.subtitle {
////                                Text(subtitle)
////                                    .font(.caption)
////                                    .foregroundColor(.secondary)
////                            }
////                        }
////                        Spacer()
////                        if let profileAvatar = getProfileAvatar(for: avatar), profileAvatar.isPrimary {
////                            Image(systemName: "star.fill")
////                                .foregroundColor(.yellow)
////                                .font(.caption)
////                        }
////                    }
////                    .swipeActions(edge: .trailing) {
////                        Button(role: .destructive) {
////                            model.removeAvatar(avatar)
////                        } label: {
////                            Label("Remove", systemImage: "trash")
////                        }
////                    }
////                }
////            } header: {
////                HStack {
////                    Text("Avatars (\(model.avatars.count))")
////                        .font(.headline)
////                        .textCase(nil)
////                    Spacer()
////                    Button("Add Avatar") {
////                        // TODO: Add avatar selection
////                    }
////                    .font(.caption)
////                }
////            }
//        }
//        .navigationTitle("Profile Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
////    private func getProfileAvatar(for avatar: Avatar) -> ProfileAvatar? {
////        // This would need to be fetched from the database
////        // For now, return nil - this is a placeholder
////        return nil
////    }
//}
//

