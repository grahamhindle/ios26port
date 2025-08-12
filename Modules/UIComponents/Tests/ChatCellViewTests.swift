import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("ChatCellView Tests")
@MainActor
struct ChatCellViewTests {

    @Test("ChatCellView initialization")
    func chatCellViewInit() {
        let chatCell = ChatCellView(
            headline: "John Doe",
            subheadline: "Hello there!",
            imageURL: "https://example.com/image.jpg",
            hasNewChat: true
        )

        #expect(chatCell.headline == "John Doe")
        #expect(chatCell.subheadline == "Hello there!")
        #expect(chatCell.imageURL == "https://example.com/image.jpg")
        #expect(chatCell.hasNewChat == true)
    }

    @Test("ChatCellView with nil imageURL")
    func chatCellViewWithNilImageURL() {
        let chatCell = ChatCellView(
            headline: "Jane Smith",
            subheadline: "How are you?",
            imageURL: nil,
            hasNewChat: false
        )

        #expect(chatCell.headline == "Jane Smith")
        #expect(chatCell.subheadline == "How are you?")
        #expect(chatCell.imageURL == nil)
        #expect(chatCell.hasNewChat == false)
    }

    @Test("ChatCellView with empty strings")
    func chatCellViewWithEmptyStrings() {
        let chatCell = ChatCellView(
            headline: "",
            subheadline: "",
            imageURL: "",
            hasNewChat: false
        )

        #expect(chatCell.headline == "")
        #expect(chatCell.subheadline == "")
        #expect(chatCell.imageURL == "")
        #expect(chatCell.hasNewChat == false)
    }
}
