import AuthenticationServices
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



public struct SignInWithAppleButtonView: View {
    
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public let style: ASAuthorizationAppleIDButton.Style
    public let cornerRadius: CGFloat

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.001)

            SignInWithAppleButtonViewRepresentable(type: type, style: style, cornerRadius: cornerRadius)
                .disabled(true)
        }
        
    }
}

private struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let cornerRadius: CGFloat

    func makeUIView(context: Context) -> some UIView {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.cornerRadius = cornerRadius
        return button
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }

    func makeCoordinator() {

    }
}

@MainActor
public struct SignInWithGoogleButtonView: View {
    public init() {}
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(.red)
            Text("Continue with Google")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
    }
}

#Preview("SignInWithAppleButtonView") {
    ZStack {
        VStack(spacing: 4) {
            SignInWithAppleButtonView(
                type: .signUp,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 50)
            
        }
        .padding(40)
    }
}


#Preview("SignInWithGoogleButtonView") {
    VStack {
        SignInWithGoogleButtonView()
            .padding()
    }
}
