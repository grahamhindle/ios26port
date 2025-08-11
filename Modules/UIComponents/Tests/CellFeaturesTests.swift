import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("Simple Cell Components Tests")
@MainActor
struct CellFeaturesTests {

    // MARK: - ChatCellView Tests

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

    // MARK: - CategoryCellView Tests

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

    // MARK: - HeroCellView Tests

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

    // MARK: - ListCellView Tests

    @Test("ListCellView initialization")
    func listCellViewInit() {
        let listCell = ListCellView(
            title: "Settings",
            subtitle: "Manage preferences",
            imageURLString: "https://example.com/settings.jpg",
            accessoryType: .disclosureIndicator,
            badge: "5"
        )

        #expect(listCell.title == "Settings")
        #expect(listCell.subtitle == "Manage preferences")
        #expect(listCell.imageURLString == "https://example.com/settings.jpg")
        #expect(listCell.badge == "5")

        // Test accessoryType enum
        switch listCell.accessoryType {
        case .disclosureIndicator:
            // Expected
            break
        default:
            #expect(Bool(false), "Expected disclosureIndicator")
        }
    }

    @Test("ListCellView with different accessory types")
    func listCellViewWithAccessoryTypes() {
        let checkmarkCell = ListCellView(
            title: "Completed",
            accessoryType: .checkmark
        )

        let customCell = ListCellView(
            title: "Custom",
            accessoryType: .custom("→")
        )

        let noneCell = ListCellView(
            title: "None",
            accessoryType: .none
        )

        #expect(checkmarkCell.title == "Completed")
        #expect(customCell.title == "Custom")
        #expect(noneCell.title == "None")

        // Test accessory types
        switch checkmarkCell.accessoryType {
        case .checkmark:
            break
        default:
            #expect(Bool(false), "Expected checkmark")
        }

        switch customCell.accessoryType {
        case let .custom(text):
            #expect(text == "→")
        default:
            #expect(Bool(false), "Expected custom")
        }

        switch noneCell.accessoryType {
        case .none:
            break
        default:
            #expect(Bool(false), "Expected none")
        }
    }

    @Test("ListCellView with minimal values")
    func listCellViewWithMinimalValues() {
        let listCell = ListCellView(title: "Simple")

        #expect(listCell.title == "Simple")
        #expect(listCell.subtitle == nil)
        #expect(listCell.imageURLString == nil)
        #expect(listCell.badge == nil)

        switch listCell.accessoryType {
        case .none:
            break
        default:
            #expect(Bool(false), "Expected none as default")
        }
    }

    // MARK: - ImageCellView Tests

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

    // MARK: - CharacterOptionCellView Tests

    @Test("CharacterOptionCellView initialization")
    func characterOptionCellViewInit() {
        let characterCell = CharacterOptionCellView(
            characterOption: .woman,
            isSelected: true,
            width: 100,
            height: 100,
            cornerRadius: 12,
            onTap: { print("Tapped woman") }
        )

        #expect(characterCell.characterOption == .woman)
        #expect(characterCell.isSelected == true)
        #expect(characterCell.width == 100)
        #expect(characterCell.height == 100)
        #expect(characterCell.cornerRadius == 12)
        #expect(characterCell.onTap != nil)
    }

    @Test("CharacterOptionCellView with default values")
    func characterOptionCellViewWithDefaults() {
        let characterCell = CharacterOptionCellView(characterOption: .man)

        #expect(characterCell.characterOption == .man)
        #expect(characterCell.isSelected == false)
        #expect(characterCell.width == 120)
        #expect(characterCell.height == 120)
        #expect(characterCell.cornerRadius == 8)
        #expect(characterCell.onTap == nil)
    }

    @Test("CharacterOptionCellView with all character options")
    func characterOptionCellViewWithAllOptions() {
        let allOptions: [CharacterOption] = [.man, .woman, .alien, .dog, .cat, .other]

        for option in allOptions {
            let characterCell = CharacterOptionCellView(
                characterOption: option,
                isSelected: option == .woman
            )

            #expect(characterCell.characterOption == option)
            #expect(characterCell.isSelected == (option == .woman))
        }
    }

    // MARK: - SelectableCharacterOption Tests

    @Test("SelectableCharacterOption initialization")
    func selectableCharacterOptionInit() {
        let selectableOption = SelectableCharacterOption(
            characterOption: .alien,
            isSelected: true
        )

        #expect(selectableOption.characterOption == .alien)
        #expect(selectableOption.isSelected == true)
        #expect(selectableOption.displayName == "Alien")
        #expect(selectableOption.id == "alien")
    }

    @Test("SelectableCharacterOption with default selection")
    func selectableCharacterOptionWithDefaultSelection() {
        let selectableOption = SelectableCharacterOption(characterOption: .dog)

        #expect(selectableOption.characterOption == .dog)
        #expect(selectableOption.isSelected == false)
        #expect(selectableOption.displayName == "Dog")
        #expect(selectableOption.id == "dog")
    }

    @Test("CharacterOption selectableOptions helper")
    func characterOptionSelectableOptionsHelper() {
        let options = CharacterOption.selectableOptions()

        #expect(options.count == CharacterOption.allCases.count)
        #expect(options.allSatisfy { !$0.isSelected })

        let optionsWithSelection = CharacterOption.selectableOptions(selectedOption: .cat)

        #expect(optionsWithSelection.count == CharacterOption.allCases.count)
        #expect(optionsWithSelection.filter { $0.isSelected }.count == 1)
        #expect(optionsWithSelection.first { $0.isSelected }?.characterOption == .cat)
    }

    // MARK: - Edge Cases

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
