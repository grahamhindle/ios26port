import SharedModels
import SwiftUI

struct UserRow: View {
    let row: UserModel.SelectedUsers

    var body: some View {
        HStack {
            // User status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 4) {
                Text(row.user.name)
                    .font(.headline)
                HStack {

                    Text(row.user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                
                if let lastSignedIn = row.user.lastSignedInDate {
                    Text("Last seen: \(formatDate(lastSignedIn))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if row.authRecord?.isAuthenticated == false {
                    Text("Guest")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private var statusColor: Color {
        if row.authRecord?.isAuthenticated == true {
            return Color(hex: row.profile?.themeColorHex ?? 0xFF5733)
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



#Preview {
    List {

       Text("Test")
    }
}
