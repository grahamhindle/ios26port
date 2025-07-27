import Foundation
import SharedResources
import SwiftUI

// MARK: - UIComponents Resource Access

@MainActor
extension SharedColors {
    /// UIComponents-specific colors
    public static let Primary = Color.blue // Use system colors
    public static let Secondary = Color.gray
}

@MainActor
extension SharedImages {
    /// UIComponents-specific images
    public static let Icon = "UIComponentsIcon"
    public static let Background = "UIComponentsBackground"
}

@MainActor
extension SharedFonts {
    /// UIComponents-specific font styles
    public static let Title = Font.custom("YourCustomFont-Bold", size: 24)
    public static let Subtitle = Font.custom("YourCustomFont-Medium", size: 18)
}

// MARK: - Localization

// UIComponents-specific localized strings
@MainActor
public struct UIComponentsStrings {
    public static let title = "UIComponents Title"
    public static let loadingMessage = "Loading UIComponents..."
    public static let errorMessage = "UIComponents Error"
    public static let retryButton = "Retry"
}
