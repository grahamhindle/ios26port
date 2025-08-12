import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("SelectableCharacterOption Tests")
@MainActor
struct SelectableCharacterOptionTests {

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
}
