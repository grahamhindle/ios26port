
import SharingGRDB
import SwiftUI
import SharedModels

@Observable
public class AvatarModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    @ObservationIgnored
    @FetchAll(Avatar.order(by: \.name)) public var avatars

    public init() {
    }

    public var avatarForm: Avatar.Draft?

    public func deleteButtonTapped(at indexSet: IndexSet) {
        withErrorReporting {
            try database.write { db in
                let ids = indexSet.map { avatars[$0].id }
                try Avatar
                    .where { $0.id.in(ids) }
                    .delete()
                    .execute(db)
            }
        }
    }
}
