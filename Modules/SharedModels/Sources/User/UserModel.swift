import Foundation
import OSLog
import SharingGRDB
import SwiftUI

@MainActor
@Observable
public final class UserModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database

    @ObservationIgnored
    @FetchAll
    public var rows: [Row]

    public var detailType: DetailType

    @Selection
    public struct Row: Sendable {
        public let user: User
    }

    private var query: some StructuredQueries.Statement<Row> {
        User
            .where {
                switch detailType {
                case .all, .users:
                    true
                case .authenticated:
                    $0.isAuthenticated
                case .guests:
                    !$0.isAuthenticated
                case .todayUsers:
                    $0.isToday
                case .freeUsers:
                    $0.isFree
                case .premiumUsers:
                    $0.isPremium
                case .enterpriseUsers:
                    $0.isEnterprise
                }
            }
            .select { user in
                Row.Columns(
                    user: user
                )
            }
            //
    }



    @ObservationIgnored
     @FetchOne(
       User.select {
         Stats.Columns(
           allCount: $0.count(),
           authenticated: $0.count(filter: $0.isAuthenticated),
           guests: $0.count(filter: !$0.isAuthenticated),
           todayCount: $0.count(filter:  $0.isToday),
           freeCount: $0.count(filter: $0.isFree),
           premiumCount: $0.count(filter: $0.isPremium),
           enterpriseCount: $0.count(filter: $0.isEnterprise)
         )
       }
     )
    public var stats = Stats()

    @Selection
    public struct Stats: Sendable {
        public var allCount = 0
        public var authenticated = 0
        public var guests = 0
        public var todayCount = 0
        public var freeCount = 0
        public var premiumCount = 0
        public var enterpriseCount = 0
      }

    public enum DetailType: Equatable {
        case all
        case authenticated
        case guests
        case todayUsers
        case freeUsers
        case premiumUsers
        case enterpriseUsers
        case users(User)

        public var navigationTitle: String {
            switch self {
                case .users( let users):
                    users.name
                case .all:
                    "All Users"
                case .authenticated:
                    "Authenticated Users"
                case .guests:
                    "Guest Users"
                case .todayUsers:
                    "Today's Users"
                case .freeUsers:
                    "Free Users"
                case .premiumUsers:
                    "Premium Users"
                case .enterpriseUsers:
                    "Enterprise Users"
            }
        }
        public var color: Color {
            switch self {
                case .users(let users):
                    //Color(hex: users.themeColorHex)
                        .black
                case .all:
                        .black
                case .authenticated:
                        .green
                case .guests:
                        .brown
                case .todayUsers:
                        .blue
                case .freeUsers:
                        .yellow.opacity(0.25)
                case .premiumUsers:
                        .yellow.opacity(0.50)
                case .enterpriseUsers:
                        .yellow.opacity(0.95)
            }
        }
    }

    public func detailTapped(detailType: DetailType) {
        print(" detail tapped \(detailType)")
        self.detailType = detailType
        _rows = FetchAll(query)
        Task {
               await updateQuery()
           }

    }

    public var searchText = ""
    public var userForm: User.Draft?
    
    public var users: [User] {
        rows.map(\.user)
    }

   

    public func addUserButtonTapped() {
        userForm = User.Draft()
    }

    public func editButtonTapped(user: User) {
        userForm = User.Draft(user)
    }

    public func deleteButtonTapped(user: User) {
        withErrorReporting {
            try database.write { db in
                try User
                    .delete(user)
                    .execute(db)
            }
        }
    }

    public func updateQuery() async {
        await withErrorReporting {
            try await $rows.load(query, animation: .default)
        }
    }

   
    public init(detailType: DetailType){
        self.detailType = detailType
        _rows = FetchAll(query)
    }

}
