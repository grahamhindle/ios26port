import Foundation
import SharedResources
import SwiftUI

// MARK: - Auth Resource Access

@MainActor
extension SharedColors {
    /// Auth-specific colors
    public static let Primary = Color.blue
    public static let Secondary = Color.gray
}

@MainActor
extension SharedImages {
    /// Auth-specific images
    public static let Icon = "AuthIcon"
    public static let Background = "AuthBackground"
}

@MainActor
extension SharedFonts {
    /// Auth-specific font styles
    public static let Title = Font.custom("YourCustomFont-Bold", size: 24)
    public static let Subtitle = Font.custom("YourCustomFont-Medium", size: 18)
}

// MARK: - Localization

@MainActor
extension String {
    public var localized: String {
        NSLocalizedString(self, tableName: "Auth", bundle: .main, comment: "")
    }
}

// Auth-specific localized strings
@MainActor
public struct AuthStrings {
    public static let title = ".title".localized
    public static let loadingMessage = ".loading".localized
    public static let errorMessage = ".error".localized
    public static let retryButton = ".retry".localized
}
