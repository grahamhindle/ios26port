import Foundation

public extension Message {

    @MainActor static let mockMessages: [Message] = [
        Message(
            id: 1,
            chatID: 1,
            content: "Hello! How can I help you today?",
            timestamp: Date().addingTimeInterval(-3600),
            isFromUser: false,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        Message(
            id: 2,
            chatID: 1,
            content: "I need help with my work project.",
            timestamp: Date().addingTimeInterval(-3500),
            isFromUser: true,
            createdAt: Date().addingTimeInterval(-3500)
        ),
        Message(
            id: 3,
            chatID: 1,
            content: "I'd be happy to assist! What specific area do you need help with?",
            timestamp: Date().addingTimeInterval(-3400),
            isFromUser: false,
            createdAt: Date().addingTimeInterval(-3400)
        ),
        Message(
            id: 4,
            chatID: 2,
            content: "Beautiful day for a walk, isn't it?",
            timestamp: Date().addingTimeInterval(-7200),
            isFromUser: false,
            createdAt: Date().addingTimeInterval(-7200)
        ),
        Message(
            id: 5,
            chatID: 2,
            content: "Absolutely! I love spending time in the park.",
            timestamp: Date().addingTimeInterval(-7100),
            isFromUser: true,
            createdAt: Date().addingTimeInterval(-7100)
        ),
        Message(
            id: 6,
            chatID: 3,
            content: "The cosmos holds infinite mysteries...",
            timestamp: Date().addingTimeInterval(-10800),
            isFromUser: false,
            createdAt: Date().addingTimeInterval(-10800)
        ),
    ]

    @MainActor static let mockMessage = mockMessages[0]
}
