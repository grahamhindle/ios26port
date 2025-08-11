import Foundation
import SharedResources
import SwiftUI

// MARK: - Auth Resource Access

@MainActor
public extension SharedColors {
    /// Auth-specific colors
    static let Primary = Color.blue
    static let Secondary = Color.gray
}

@MainActor
public extension SharedImages {
    /// Auth-specific images
    static let Icon = "AuthIcon"
    static let Background = "AuthBackground"
}

@MainActor
public extension SharedFonts {
    /// Auth-specific font styles
    static let Title = Font.custom("YourCustomFont-Bold", size: 24)
    static let Subtitle = Font.custom("YourCustomFont-Medium", size: 18)
}

// MARK: - Localization

@MainActor
public extension String {
    var localized: String {
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
