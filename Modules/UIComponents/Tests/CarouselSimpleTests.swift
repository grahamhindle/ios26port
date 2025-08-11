import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("Simple Carousel Tests")
@MainActor
struct CarouselSimpleTests {

    // Sample test data
    struct TestItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }

    // MARK: - Basic Functionality Tests

    @Test("CarouselView initializes with empty items")
    func carouselWithEmptyItems() {
        let items: [TestItem] = []
        let carousel = CarouselView(items: items) { item in
            Text(item.title)
        }

        // View should be created successfully
        #expect(carousel.items.isEmpty)
    }

    @Test("CarouselView initializes with items")
    func carouselWithItems() {
        let items = [
            TestItem(title: "Item 1", subtitle: "Subtitle 1"),
            TestItem(title: "Item 2", subtitle: "Subtitle 2"),
        ]

        let carousel = CarouselView(items: items) { item in
            Text(item.title)
        }

        #expect(carousel.items.count == 2)
        #expect(carousel.items[0].title == "Item 1")
        #expect(carousel.items[1].title == "Item 2")
    }

    @Test("CarouselView with custom configuration")
    func carouselWithCustomConfiguration() {
        let items = [TestItem(title: "Test", subtitle: "Test")]

        let carousel = CarouselView(
            items: items,
            itemSpacing: 20,
            itemWidth: 300,
            itemHeight: 250,
            showIndicators: false
        ) { item in
            Text(item.title)
        }

        #expect(carousel.itemSpacing == 20)
        #expect(carousel.itemWidth == 300)
        #expect(carousel.itemHeight == 250)
        #expect(carousel.showIndicators == false)
    }

    // MARK: - CarouselCard Tests

    @Test("CarouselCard initialization")
    func carouselCardInit() {
        let card1 = CarouselCard(title: "Test Title")
        let card2 = CarouselCard(
            title: "Test Title",
            subtitle: "Test Subtitle",
            imageURL: "https://example.com/image.jpg",
            cornerRadius: 8
        )

        #expect(card1.title == "Test Title")
        #expect(card1.subtitle == nil)
        #expect(card1.imageURL == nil)
        #expect(card1.cornerRadius == 12) // default value

        #expect(card2.title == "Test Title")
        #expect(card2.subtitle == "Test Subtitle")
        #expect(card2.imageURL == "https://example.com/image.jpg")
        #expect(card2.cornerRadius == 8)
    }

    // MARK: - CarouselIndicators Tests

    @Test("CarouselIndicators initialization")
    func carouselIndicatorsInit() {
        let currentIndex = Binding.constant(0)
        let indicators = CarouselIndicators(currentIndex: currentIndex, totalItems: 3)

        #expect(indicators.totalItems == 3)
    }

    // MARK: - EmptyCarouselView Tests

    @Test("EmptyCarouselView creation")
    func emptyCarouselViewCreation() {
        let emptyView = EmptyCarouselView()

        // View should be created successfully
        _ = emptyView
    }

    // MARK: - Integration Tests

    @Test("CarouselView with real data structure")
    func carouselWithRealData() {
        struct DemoItem: Identifiable {
            let id = UUID()
            let title: String
            let subtitle: String
            let imageURL: String?
        }

        let items = [
            DemoItem(title: "Demo 1", subtitle: "Subtitle 1", imageURL: "https://picsum.photos/300/200?random=1"),
            DemoItem(title: "Demo 2", subtitle: "Subtitle 2", imageURL: "https://picsum.photos/300/200?random=2"),
            DemoItem(title: "Demo 3", subtitle: "Subtitle 3", imageURL: nil),
        ]

        let carousel = CarouselView(items: items) { item in
            CarouselCard(
                title: item.title,
                subtitle: item.subtitle,
                imageURL: item.imageURL
            )
        }

        #expect(carousel.items.count == 3)
        #expect(carousel.items[0].title == "Demo 1")
        #expect(carousel.items[1].imageURL?.contains("picsum.photos") == true)
        #expect(carousel.items[2].imageURL == nil)
    }

    // MARK: - Edge Cases

    @Test("CarouselView with single item")
    func carouselWithSingleItem() {
        let items = [TestItem(title: "Single Item", subtitle: "Only one")]

        let carousel = CarouselView(items: items) { item in
            Text(item.title)
        }

        #expect(carousel.items.count == 1)
        #expect(carousel.items[0].title == "Single Item")
    }

    @Test("CarouselCard with nil values")
    func carouselCardWithNilValues() {
        let card = CarouselCard(
            title: "Title Only",
            subtitle: nil,
            imageURL: nil
        )

        #expect(card.title == "Title Only")
        #expect(card.subtitle == nil)
        #expect(card.imageURL == nil)
    }

    @Test("CarouselCard with empty strings")
    func carouselCardWithEmptyStrings() {
        let card = CarouselCard(
            title: "",
            subtitle: "",
            imageURL: ""
        )

        #expect(card.title == "")
        #expect(card.subtitle == "")
        #expect(card.imageURL == "")
    }

    @Test("CarouselView with special characters")
    func carouselWithSpecialCharacters() {
        let items = [
            TestItem(title: "🚀 Rocket", subtitle: "Space travel"),
            TestItem(title: "Émoji tést", subtitle: "Spëcial chärs"),
            TestItem(title: "Multi\nline\ntext", subtitle: "Line breaks"),
        ]

        let carousel = CarouselView(items: items) { item in
            Text(item.title)
        }

        #expect(carousel.items.count == 3)
        #expect(carousel.items[0].title == "🚀 Rocket")
        #expect(carousel.items[1].title == "Émoji tést")
        #expect(carousel.items[2].title.contains("\n"))
    }
}
