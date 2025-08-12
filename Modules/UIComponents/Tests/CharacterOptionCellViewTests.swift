import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("CharacterOptionCellView Tests")
@MainActor
struct CharacterOptionCellViewTests {

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
}
