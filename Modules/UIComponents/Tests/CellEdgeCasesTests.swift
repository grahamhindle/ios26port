import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("Cell Edge Cases Tests")
@MainActor
struct CellEdgeCasesTests {

    @Test("Cell views with special characters")
    func cellViewsWithSpecialCharacters() {
        let chatCell = ChatCellView(
            headline: "🚀 Rocket User",
            subheadline: "Message with émojis and spëcial chars!"
        )

        let categoryCell = CategoryCellView(title: "🌟 Special Category")

        let heroCell = HeroCellView(
            title: "🎉 Welcome!",
            subtitle: "Let's gö tögether",
            callToAction: "Stärt Now"
        )

        let listCell = ListCellView(
            title: "⚙️ Settings",
            subtitle: "Configuratiön & Preferences"
        )

        let imageCell = ImageCellView(
            title: "🖼️ Beautiful Image",
            subtitle: "Taken at 日本"
        )

        #expect(chatCell.headline == "🚀 Rocket User")
        #expect(categoryCell.title == "🌟 Special Category")
        #expect(heroCell.title == "🎉 Welcome!")
        #expect(listCell.title == "⚙️ Settings")
        #expect(imageCell.title == "🖼️ Beautiful Image")
    }

    @Test("Cell views with very long text")
    func cellViewsWithLongText() {
        // swiftlint:disable:next line_length
        let longText = "This is a very long text that should be handled gracefully by the cell components. It contains multiple sentences and should test the line limits and text wrapping behavior of the components."

        let chatCell = ChatCellView(
            headline: longText,
            subheadline: longText
        )

        let categoryCell = CategoryCellView(title: longText)

        let heroCell = HeroCellView(
            title: longText,
            subtitle: longText,
            callToAction: longText
        )

        let listCell = ListCellView(
            title: longText,
            subtitle: longText
        )

        let imageCell = ImageCellView(
            title: longText,
            subtitle: longText
        )

        // Views should handle long text gracefully
        #expect(chatCell.headline == longText)
        #expect(categoryCell.title == longText)
        #expect(heroCell.title == longText)
        #expect(listCell.title == longText)
        #expect(imageCell.title == longText)
    }

    @Test("Cell views with extreme dimensions")
    func cellViewsWithExtremeDimensions() {
        let extremelyLargeCategory = CategoryCellView(
            title: "Large",
            width: 1000,
            height: 1000
        )

        let extremelySmallCategory = CategoryCellView(
            title: "Small",
            width: 1,
            height: 1
        )

        let extremelyLargeImage = ImageCellView(
            title: "Large Image",
            width: 2000,
            height: 2000
        )

        let extremelySmallImage = ImageCellView(
            title: "Small Image",
            width: 0,
            height: 0
        )

        // Views should handle extreme dimensions gracefully
        #expect(extremelyLargeCategory.width == 1000)
        #expect(extremelySmallCategory.width == 1)
        #expect(extremelyLargeImage.width == 2000)
        #expect(extremelySmallImage.width == 0)
    }
}
