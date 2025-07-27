import Foundation

public extension Chat {
    
    @MainActor static let mockChats: [Chat] = [
        Chat(
            id: 1,
            userID: 1,
            avatarID: 1,
            title: "Work Discussion",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Chat(
            id: 2,
            userID: 1,
            avatarID: 2,
            title: "Casual Conversation",
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date().addingTimeInterval(-3600)
        ),
        Chat(
            id: 3,
            userID: 2,
            avatarID: 3,
            title: "Space Adventures",
            createdAt: Date().addingTimeInterval(-172800),
            updatedAt: Date().addingTimeInterval(-7200)
        )
    ]
    
    @MainActor static let mockChat = mockChats[0]
}