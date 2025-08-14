import Foundation
import SharingGRDB
import SwiftUI
import Testing

@testable import Reminders

@Suite(
  .dependencies {
    $0.date.now = baseDate
    $0.defaultDatabase = try Reminders.appDatabase()
    try $0.defaultDatabase.write { try $0.seedTestData() }
  }
)
struct BaseTestSuite {}

extension Database {
    let baseDate = baseDate
    try self.seed {
        try seedAvatarTestData()
    }
}

