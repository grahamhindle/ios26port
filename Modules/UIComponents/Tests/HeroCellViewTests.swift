import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("HeroCellView Tests")
@MainActor
struct HeroCellViewTests {

    @Test("HeroCellView initialization")
    func heroCellViewInit() {
        let heroCell = HeroCellView(
            title: "Welcome",
            subtitle: "Get started today",
            imageURLString: "https://example.com/hero.jpg",
            callToAction: "Learn More",
            backgroundColor: .blue
        )

        #expect(heroCell.title == "Welcome")
        #expect(heroCell.subtitle == "Get started today")
        #expect(heroCell.imageURLString == "https://example.com/hero.jpg")
        #expect(heroCell.callToAction == "Learn More")
        #expect(heroCell.backgroundColor == .blue)
    }

    @Test("HeroCellView with nil values")
    func heroCellViewWithNilValues() {
        let heroCell = HeroCellView(
            title: nil,
            subtitle: nil,
            imageURLString: nil,
            callToAction: nil,
            backgroundColor: nil
        )

        #expect(heroCell.title == nil)
        #expect(heroCell.subtitle == nil)
        #expect(heroCell.imageURLString == nil)
        #expect(heroCell.callToAction == nil)
        #expect(heroCell.backgroundColor == nil)
    }

    @Test("HeroCellView with partial values")
    func heroCellViewWithPartialValues() {
        let heroCell = HeroCellView(
            title: "Only Title",
            subtitle: nil,
            imageURLString: "https://example.com/image.jpg"
        )

        #expect(heroCell.title == "Only Title")
        #expect(heroCell.subtitle == nil)
        #expect(heroCell.imageURLString == "https://example.com/image.jpg")
        #expect(heroCell.callToAction == nil)
        #expect(heroCell.backgroundColor == nil)
    }
}
