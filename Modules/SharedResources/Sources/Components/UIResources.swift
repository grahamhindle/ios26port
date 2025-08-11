// Update Modules/SharedResources/Sources/SharedResources.swift

import SwiftUI

// MARK: - Color Extensions

@MainActor
public enum SharedResources {}
public extension Theme {
    var hexColor: String {
        switch self {
        case .bubblegum: "#FFC1CC"
        case .buttercup: "#FFF200"
        case .indigo: "#4B0082"
        case .lavender: "#B57EDC"
        case .magenta: "#FF00FF"
        case .navy: "#001F6E"
        case .orange: "#FFA500"
        case .oxblood: "#4A0404"
        case .periwinkle: "#8F99FB"
        case .poppy: "#FF3855"
        case .purple: "#800080"
        case .seafoam: "#93E9BE"
        case .sky: "#87CEEB"
        case .tan: "#D2B48C"
        case .teal: "#008080"
        case .yellow: "#FFFF00"
        }
    }
}

public enum Theme: String, CaseIterable, Equatable, Identifiable, Codable {
    public var id: Self { self }

    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow

    public var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan,
             .teal, .yellow:
            .black
        case .indigo, .magenta, .navy, .oxblood, .purple:
            .white
        }
    }

    public var color: Color {
        switch self {
        case .bubblegum: Color.pink
        case .buttercup: Color.yellow
        case .indigo: Color.indigo
        case .lavender: Color.purple.opacity(0.7)
        case .magenta: Color.pink
        case .navy: Color.blue.opacity(0.8)
        case .orange: Color.orange
        case .oxblood: Color.red.opacity(0.8)
        case .periwinkle: Color.blue.opacity(0.6)
        case .poppy: Color.red
        case .purple: Color.purple
        case .seafoam: Color.mint
        case .sky: Color.cyan
        case .tan: Color.brown.opacity(0.6)
        case .teal: Color.teal
        case .yellow: Color.yellow
        }
    }
}

// MARK: - Button Styles (Swift 6 compliant)

@MainActor
public extension View {
    func removeListRowFormatting() -> some View {
        listRowInsets(EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        ))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    func addingGradientBackgroundForText() -> some View {
        background(
            LinearGradient(
                colors: [
                    .clear, .black.opacity(0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Layout Constants

public struct SharedLayout: Sendable {
    public static let padding: CGFloat = 16
    public static let smallPadding: CGFloat = 8
    public static let largePadding: CGFloat = 24
    public static let cornerRadius: CGFloat = 8
    public static let borderWidth: CGFloat = 1
    public static let borderWidth2: CGFloat = 4
    public static let buttonHeight: CGFloat = 55
}

// MARK: - Animation Constants

public enum SharedAnimations {
    public static let quickTransition = Animation.easeInOut(duration: 0.2)
    public static let standardTransition = Animation.easeInOut(duration: 0.3)
    public static let slowTransition = Animation.easeInOut(duration: 0.5)
}
