import SwiftUI
import SharedResources
import SharedModels

// MARK: - Legacy Support Note
// This file is maintained for backward compatibility.
// New code should use the simple cell components in CellFeatures.swift directly.

// MARK: - Character Option Selection Support

public struct SelectableCharacterOption: Equatable, Identifiable, Sendable {
    public let id: String
    public let characterOption: CharacterOption
    public var isSelected: Bool

    public var displayName: String {
        characterOption.displayName
    }

    public init(characterOption: CharacterOption, isSelected: Bool = false) {
        id = characterOption.rawValue
        self.characterOption = characterOption
        self.isSelected = isSelected
    }
}

// MARK: - Character Option Grid View

public struct CharacterOptionGridView: View {
    public let options: [SelectableCharacterOption]
    public let onSelectionChange: (CharacterOption) -> Void
    public let columns: Int
    public let cellWidth: CGFloat
    public let cellHeight: CGFloat
    public let spacing: CGFloat
    
    public init(
        options: [SelectableCharacterOption],
        onSelectionChange: @escaping (CharacterOption) -> Void,
        columns: Int = 3,
        cellWidth: CGFloat = 100,
        cellHeight: CGFloat = 100,
        spacing: CGFloat = 16
    ) {
        self.options = options
        self.onSelectionChange = onSelectionChange
        self.columns = columns
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.spacing = spacing
    }
    
    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
            ForEach(options) { option in
                CharacterOptionCellView(
                    characterOption: option.characterOption,
                    isSelected: option.isSelected,
                    width: cellWidth,
                    height: cellHeight,
                    onTap: {
                        onSelectionChange(option.characterOption)
                    }
                )
            }
        }
        .padding(spacing)
    }
}

// MARK: - Helper Functions

extension CharacterOption {
    public static func selectableOptions(selectedOption: CharacterOption? = nil) -> [SelectableCharacterOption] {
        CharacterOption.allCases.map { option in
            SelectableCharacterOption(
                characterOption: option,
                isSelected: option == selectedOption
            )
        }
    }
}

// MARK: - Preview

#Preview("Character Option Grid") {
    CharacterOptionGridView(
        options: CharacterOption.selectableOptions(selectedOption: .woman),
        onSelectionChange: { option in
            print("Selected: \(option.displayName)")
        }
    )
    .padding()
}
