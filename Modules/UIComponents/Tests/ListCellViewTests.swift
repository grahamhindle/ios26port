import DatabaseModule
import Foundation
import SwiftUI
import Testing
@testable import UIComponents

@Suite("ListCellView Tests")
@MainActor
struct ListCellViewTests {

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
}
