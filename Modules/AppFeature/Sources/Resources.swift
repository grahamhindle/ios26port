import Foundation
import SharedResources
import SwiftUI

// MARK: - App Resource Access

@MainActor
public extension SharedColors {
    /// App-specific colors
    static let Primary = Color.blue
    static let Secondary = Color.gray
}

@MainActor
public extension SharedImages {
    /// App-specific images
    static let Icon = "AppIcon"
    static let Background = "AppBackground"
}

@MainActor
public extension SharedFonts {
    /// App-specific font styles
    static let Title = Font.custom("YourCustomFont-Bold", size: 24)
    static let Subtitle = Font.custom("YourCustomFont-Medium", size: 18)
}

// MARK: - Localization

@MainActor
public extension String {
    var localized: String {
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
