import Foundation
import SharedModels
import SharingGRDB


@Observable
public class AuthFeature {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database
    public init() {}

    @ObservationIgnored
    @FetchAll var authorizedUsers: [AuthenticationRecord] = []
      


}


