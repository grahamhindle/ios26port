import SwiftUI

public enum ButtonStyleOptions {
    case badge
    case highlight
    case pressable
    case primary
    case secondary
    case tertiary
    case callToAction
    case toolbar
}

public extension View {
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOptions = .primary, action: @escaping () -> ()) -> some View {
        switch option {
        case .badge:
            badgeButton(action: action)
        case .callToAction:
            callToActionButton(action: action)
        case .highlight:
            highlightButton(action: action)
        case .pressable:
            pressableButton(action: action)
        case .primary:
            primaryButton(action: action)
        case .secondary:
            secondaryButton(action: action)
        case .tertiary:
            tertiaryButton(action: action)
        case .toolbar:
            toolbarButton(action: action)
        }
    }

    func badgeButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(BadgeButtonStyle())
    }

    func highlightButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }

    func pressableButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }

    func primaryButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    func secondaryButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(SecondaryButtonStyle())
    }

    func tertiaryButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(TertiaryButtonStyle())
    }

    func callToActionButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(CallToActionButtonStyle())
    }

    func toolbarButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(ToolbarButtonStyle())
    }
}

@MainActor
public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.title)
            .foregroundColor(SharedColors.primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@MainActor
public struct CallToActionButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(SharedColors.accent)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@MainActor
public struct BadgeButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(SharedColors.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

public struct HighlightButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? SharedColors.accent.opacity(0.4) : Color.clear.opacity(0)
            }
            .cornerRadius(8)
            .animation(.smooth, value: configuration.isPressed)
    }
}

public struct PressableButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.smooth, value: configuration.isPressed)
    }
}

@MainActor
public struct SecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.headline)
            .foregroundColor(SharedColors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SharedColors.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@MainActor
public struct TertiaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.body)
            .foregroundColor(SharedColors.primary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@MainActor
public struct ToolbarButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SharedFonts.caption)
            .foregroundColor(SharedColors.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? SharedColors.accent.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SharedColors.accent, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
