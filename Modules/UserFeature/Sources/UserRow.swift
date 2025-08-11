import Foundation
import DatabaseModule
import SharedResources
import SharingGRDB
import SwiftUI

public struct UserRow: View {
    let user: User

    public init(user: User) {
        self.user = user
    }

    public var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: user.membershipStatus.color))
                .frame(width: 16, height: 16)
            Text(user.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                if let lastSignedIn = user.lastSignedInDate {
                    Text("Last seen: \(formatDate(lastSignedIn))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if !user.isAuthenticated {
                    Text("Guest")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 120, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private var statusColor: Color {
        if user.isAuthenticated {
            return Color(hex: user.themeColorHex)
        } else {
            return .gray
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct UserRowPreview: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable redundant_discardable_let
        let _ = prepareDependencies {
            // swiftlint:disable force_try
            $0.defaultDatabase = try! appDatabase()
            // swiftlint:enable force_try
        }

        NavigationStack {
            List {
                UserRow(
                    user: User(
                        id: 1,
                        name: "Graham",
                        isAuthenticated: false,
                        membershipStatus: .free,
                        authorizationStatus: .guest,
                        themeColorHex: 0xEF7E_4AFF
                    )
                )
            }
        }
        // swiftlint:enable redundant_discardable_let
    }
}
