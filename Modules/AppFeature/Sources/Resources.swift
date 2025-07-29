import Foundation
import SharedResources
import SwiftUI

// MARK: - App Resource Access

@MainActor
extension SharedColors {
    /// App-specific colors
    public static let Primary = Color.blue
    public static let Secondary = Color.gray
}

@MainActor
extension SharedImages {
    /// App-specific images
    public static let Icon = "AppIcon"
    public static let Background = "AppBackground"
}

@MainActor
extension SharedFonts {
    /// App-specific font styles
    public static let Title = Font.custom("YourCustomFont-Bold", size: 24)
    public static let Subtitle = Font.custom("YourCustomFont-Medium", size: 18)
}

// MARK: - Localization

@MainActor
extension String {
    public var localized: String {
        NSLocalizedString(self, tableName: "App", bundle: .main, comment: "")
    }
}

// App-specific localized strings
@MainActor
public struct AppStrings {
    public static let title = ".title".localized
    public static let loadingMessage = ".loading".localized
    public static let errorMessage = ".error".localized
    public static let retryButton = ".retry".localized
}
