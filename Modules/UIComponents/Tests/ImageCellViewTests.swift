import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("ImageCellView Tests")
@MainActor
struct ImageCellViewTests {

    @Test("ImageCellView initialization")
    func imageCellViewInit() {
        let imageCell = ImageCellView(
            title: "Beautiful Photo",
            subtitle: "Taken at sunset",
            imageURLString: "https://example.com/photo.jpg",
            width: 300,
            height: 200,
            cornerRadius: 16
        )

        #expect(imageCell.title == "Beautiful Photo")
        #expect(imageCell.subtitle == "Taken at sunset")
        #expect(imageCell.imageURLString == "https://example.com/photo.jpg")
        #expect(imageCell.width == 300)
        #expect(imageCell.height == 200)
        #expect(imageCell.cornerRadius == 16)
    }

    @Test("ImageCellView with nil values")
    func imageCellViewWithNilValues() {
        let imageCell = ImageCellView(
            title: nil,
            subtitle: nil,
            imageURLString: nil,
            width: nil,
            height: nil
        )

        #expect(imageCell.title == nil)
        #expect(imageCell.subtitle == nil)
        #expect(imageCell.imageURLString == nil)
        #expect(imageCell.width == nil)
        #expect(imageCell.height == nil)
        #expect(imageCell.cornerRadius == 8) // default value
    }

    @Test("ImageCellView with default corner radius")
    func imageCellViewWithDefaultCornerRadius() {
        let imageCell = ImageCellView(title: "Test")

        #expect(imageCell.title == "Test")
        #expect(imageCell.cornerRadius == 8)
    }
}
