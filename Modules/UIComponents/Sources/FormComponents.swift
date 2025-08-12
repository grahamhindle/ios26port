import SharedResources
import SwiftUI

// MARK: - Form Components

/// Reusable image picker button component with consistent styling
public struct ImagePickerButton: View {
    let imageURL: String?
    let size: CGFloat
    let title: String
    let subtitle: String
    let action: () -> Void

    public init(
        imageURL: String?,
        size: CGFloat,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) {
        self.imageURL = imageURL
        self.size = size
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    // Image or Placeholder
                    if let urlString = imageURL, !urlString.isEmpty {
                        AsyncImageView(avatarURL: URL(string: urlString))
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: size, height: size)
                            .overlay(
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: size * 0.3))
                                    .foregroundColor(.gray)
                            )
                    }

                    // Border and Camera Icon
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .opacity(0.7)
                        .frame(width: size, height: size)

                    // Camera Icon Overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "camera.fill")
                                .font(.system(size: size * 0.15))
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: size * 0.25, height: size * 0.25)
                                )
                                .offset(x: -size * 0.05, y: -size * 0.05)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Labels
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Generic picker row component for form sections
public struct PickerRow<T: CaseIterable & Hashable>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let selection: Binding<T?>
    let options: [T]
    let getIcon: (T) -> String
    let getDisplayName: (T) -> String

    public init(
        icon: String,
        iconColor: Color,
        title: String,
        selection: Binding<T?>,
        options: [T],
        getIcon: @escaping (T) -> String,
        getDisplayName: @escaping (T) -> String
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.selection = selection
        self.options = options
        self.getIcon = getIcon
        self.getDisplayName = getDisplayName
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)

            Picker(title, selection: selection) {
                Text("Select \(title)").tag(T?.none)
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(getIcon(option))
                        Text(getDisplayName(option))
                    }.tag(T?.some(option))
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Form Styling Extensions

public extension View {
    /// Applies consistent form section spacing and background
    func formSectionSpacing(_ spacing: CGFloat = 4.0) -> some View {
        listSectionSpacing(spacing)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
    }
}
