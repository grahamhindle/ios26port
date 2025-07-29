import Foundation

public extension ProfileAvatar {
    static let mockData: [ProfileAvatar] = [
        ProfileAvatar(
            id: 1,
            profileID: 1, // John Doe
            avatarID: 1,  // First avatar
            dateAdded: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15)),
            isPrimary: true
        ),
        ProfileAvatar(
            id: 2,
            profileID: 1, // John Doe
            avatarID: 2,  // Second avatar
            dateAdded: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 20)),
            isPrimary: false
        ),
        ProfileAvatar(
            id: 3,
            profileID: 2, // Jane Smith
            avatarID: 2,  // Shared avatar
            dateAdded: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 10)),
            isPrimary: true
        ),
        ProfileAvatar(
            id: 4,
            profileID: 2, // Jane Smith
            avatarID: 3,  // Third avatar
            dateAdded: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 25)),
            isPrimary: false
        ),
        ProfileAvatar(
            id: 5,
            profileID: 3, // Bob Johnson
            avatarID: 1,  // Shared avatar
            dateAdded: Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 5)),
            isPrimary: true
        )
    ]
}