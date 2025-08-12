import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("CategoryCellView Tests")
@MainActor
struct CategoryCellViewTests {

    @Test("CategoryCellView initialization")
    func categoryCellViewInit() {
        let categoryCell = CategoryCellView(
            title: "Nature",
            imageURLString: "https://example.com/nature.jpg",
            width: 200,
            height: 150,
            cornerRadius: 12,
            isSelected: true,
            onTap: { print("Tapped") }
        )

        #expect(categoryCell.title == "Nature")
        #expect(categoryCell.imageURLString == "https://example.com/nature.jpg")
        #expect(categoryCell.width == 200)
        #expect(categoryCell.height == 150)
        #expect(categoryCell.cornerRadius == 12)
        #expect(categoryCell.isSelected == true)
        #expect(categoryCell.onTap != nil)
    }

    @Test("CategoryCellView with default values")
    func categoryCellViewWithDefaults() {
        let categoryCell = CategoryCellView(title: "City")

        #expect(categoryCell.title == "City")
        #expect(categoryCell.imageURLString == nil)
        #expect(categoryCell.width == 150)
        #expect(categoryCell.height == 150)
        #expect(categoryCell.cornerRadius == 8)
        #expect(categoryCell.isSelected == false)
        #expect(categoryCell.onTap == nil)
    }

    @Test("CategoryCellView with nil imageURL")
    func categoryCellViewWithNilImageURL() {
        let categoryCell = CategoryCellView(
            title: "Test",
            imageURLString: nil,
            isSelected: false
        )

        #expect(categoryCell.title == "Test")
        #expect(categoryCell.imageURLString == nil)
        #expect(categoryCell.isSelected == false)
    }
}
