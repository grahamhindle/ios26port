import SwiftUI

// MARK: - Color Extensions

public extension Int {
    var swiftUIColor: Color {
        get {
            Color(hex: self)
        }
        set {
            guard let components = UIColor(newValue).cgColor.components
            else { return }
            let redComponent = Int(components[0] * 255) << 24
            let greenComponent = Int(components[1] * 255) << 16
            let blueComponent = Int(components[2] * 255) << 8
            let alphaComponent = Int((components.indices.contains(3) ? components[3] : 1) * 255)
            self = redComponent | greenComponent | blueComponent | alphaComponent
        }
    }
}

public extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 24) & 0xFF) / 255.0,
            green: Double((hex >> 16) & 0xFF) / 255.0,
            blue: Double((hex >> 8) & 0xFF) / 255.0,
            opacity: Double(hex & 0xFF) / 255.0
        )
    }

    var hexValue: Int {
        guard let components = UIColor(self).cgColor.components
        else { return 0xFF5733_ff }
        let redComponent = Int(components[0] * 255) << 24
        let greenComponent = Int(components[1] * 255) << 16
        let blueComponent = Int(components[2] * 255) << 8
        let alphaComponent = Int((components.indices.contains(3) ? components[3] : 1) * 255)
        return redComponent | greenComponent | blueComponent | alphaComponent
    }
}

public extension Color {
    /// Initialize a Color from a hex string
    /// Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

@MainActor
public enum SharedColors {
    // Use system colors that always exist instead of asset catalog colors
    public static let primary = Color.blue
    public static let secondary = Color.gray
    public static let tertiary = Color.gray.opacity(0.2)
    public static let green = Color.green
    public static let orange = Color.orange
    public static let accent = Color(hex: "#FF5757") // Custom hex color
    public static let black = Color.black
    public static let white = Color.white
    public static let text = Color.primary
    public static let secondaryText = Color.secondary
    public static let error = Color.red
    public static let success = Color.green
    public static let warning = Color.yellow
    public static let background = Color(.systemBackground)
    public static let surface = Color(.secondarySystemBackground)
    public static let tappableBackground = background.opacity(0.001)
}
