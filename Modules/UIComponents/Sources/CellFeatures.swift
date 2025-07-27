import SwiftUI
import SharedResources
import SharedModels

// MARK: - Simple Cell Components

// MARK: - Chat Cell View

public struct ChatCellView: View {
    public let headline: String
    public let subheadline: String
    public let imageURL: String?
    public let hasNewChat: Bool
    
    public init(
        headline: String,
        subheadline: String,
        imageURL: String? = nil,
        hasNewChat: Bool = false
    ) {
        self.headline = headline
        self.subheadline = subheadline
        self.imageURL = imageURL
        self.hasNewChat = hasNewChat
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            AsyncImageView(
                avatarURL: URL(string: imageURL ?? ""),
                size: 50
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(headline)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(subheadline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // New Chat Badge
            if hasNewChat {
                Text("New")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Category Cell View

public struct CategoryCellView: View {
    public let title: String
    public let imageURLString: String?
    public let width: CGFloat
    public let height: CGFloat
    public let cornerRadius: CGFloat
    public let isSelected: Bool
    public let onTap: (() -> Void)?
    
    public init(
        title: String,
        imageURLString: String? = nil,
        width: CGFloat = 150,
        height: CGFloat = 150,
        cornerRadius: CGFloat = 8,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.imageURLString = imageURLString
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            onTap?()
        }) {
            AsyncImageView(
                url: URL(string: imageURLString ?? ""),
                width: width,
                height: height,
                cornerRadius: cornerRadius,
                contentMode: .fill,
                placeholderImage: "photo"
            )
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .disabled(onTap == nil)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Hero Cell View

public struct HeroCellView: View {
    public let title: String?
    public let subtitle: String?
    public let imageURLString: String?
    public let callToAction: String?
    public let backgroundColor: Color?
    
    public init(
        title: String? = nil,
        subtitle: String? = nil,
        imageURLString: String? = nil,
        callToAction: String? = nil,
        backgroundColor: Color? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURLString = imageURLString
        self.callToAction = callToAction
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        AsyncImageView(
            heroURL: URL(string: imageURLString ?? ""),
            height: 200
        )
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 8) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if let callToAction = callToAction {
                    Text(callToAction)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .background(backgroundColor ?? Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - List Cell View

public struct ListCellView: View {
    public let title: String
    public let subtitle: String?
    public let imageURLString: String?
    public let accessoryType: AccessoryType
    public let badge: String?
    
    public enum AccessoryType {
        case none
        case disclosureIndicator
        case checkmark
        case custom(String)
    }
    
    public init(
        title: String,
        subtitle: String? = nil,
        imageURLString: String? = nil,
        accessoryType: AccessoryType = .none,
        badge: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURLString = imageURLString
        self.accessoryType = accessoryType
        self.badge = badge
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Leading Image
            AsyncImageView(
                thumbnailURL: URL(string: imageURLString ?? ""),
                width: 60,
                height: 60,
                cornerRadius: 12
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trailing Content
            HStack(spacing: 8) {
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                AccessoryView(accessoryType: accessoryType)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
    }
}

private struct AccessoryView: View {
    let accessoryType: ListCellView.AccessoryType
    
    var body: some View {
        switch accessoryType {
        case .none:
            EmptyView()
        case .disclosureIndicator:
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        case .checkmark:
            Image(systemName: "checkmark")
                .foregroundColor(.blue)
                .font(.caption)
        case let .custom(text):
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Image Cell View

public struct ImageCellView: View {
    public let title: String?
    public let subtitle: String?
    public let imageURLString: String?
    public let width: CGFloat?
    public let height: CGFloat?
    public let cornerRadius: CGFloat
    
    public init(
        title: String? = nil,
        subtitle: String? = nil,
        imageURLString: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 8
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURLString = imageURLString
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(
                url: URL(string: imageURLString ?? ""),
                width: width,
                height: height,
                cornerRadius: cornerRadius,
                contentMode: .fill,
                placeholderImage: "photo"
            )
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
        }
    }
}

// MARK: - Character Option Category Cell

public struct CharacterOptionCellView: View {
    public let characterOption: CharacterOption
    public let isSelected: Bool
    public let width: CGFloat
    public let height: CGFloat
    public let cornerRadius: CGFloat
    public let onTap: (() -> Void)?
    
    public init(
        characterOption: CharacterOption,
        isSelected: Bool = false,
        width: CGFloat = 120,
        height: CGFloat = 120,
        cornerRadius: CGFloat = 8,
        onTap: (() -> Void)? = nil
    ) {
        self.characterOption = characterOption
        self.isSelected = isSelected
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.onTap = onTap
    }
    
    public var body: some View {
        CategoryCellView(
            title: characterOption.displayName,
            imageURLString: ImageURLGenerator.randomPicsum()?.absoluteString,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            isSelected: isSelected,
            onTap: onTap
        )
    }
}

// MARK: - Helper Extensions

extension View {
    public func removeListRowFormatting() -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

// MARK: - Preview

#Preview("Chat Cell") {
    VStack(spacing: 16) {
        ChatCellView(
            headline: "John Doe",
            subheadline: "Hey, how are you doing? I hope everything is going well!",
            imageURL: "https://picsum.photos/100/100?random=1",
            hasNewChat: true
        )
        
        ChatCellView(
            headline: "Jane Smith",
            subheadline: "Thanks for the help yesterday",
            imageURL: "https://picsum.photos/100/100?random=2",
            hasNewChat: false
        )
    }
    .padding()
}

#Preview("Category Cell") {
    HStack(spacing: 16) {
        CategoryCellView(
            title: "Nature",
            imageURLString: "https://picsum.photos/150/150?random=3",
            isSelected: true
        )
        
        CategoryCellView(
            title: "City",
            imageURLString: "https://picsum.photos/150/150?random=4",
            isSelected: false
        )
    }
    .padding()
}

#Preview("Hero Cell") {
    HeroCellView(
        title: "Welcome to Our App",
        subtitle: "Discover amazing features and connect with people",
        imageURLString: "https://picsum.photos/400/200?random=5",
        callToAction: "Get Started"
    )
    .padding()
}

#Preview("List Cell") {
    VStack(spacing: 8) {
        ListCellView(
            title: "Settings",
            subtitle: "Manage your preferences",
            imageURLString: "https://picsum.photos/60/60?random=6",
            accessoryType: .disclosureIndicator
        )
        
        ListCellView(
            title: "Notifications",
            subtitle: "5 new messages",
            imageURLString: "https://picsum.photos/60/60?random=7",
            accessoryType: .checkmark,
            badge: "5"
        )
    }
    .padding()
}

#Preview("Image Cell") {
    HStack(spacing: 16) {
        ImageCellView(
            title: "Beautiful Sunset",
            subtitle: "Captured at the beach",
            imageURLString: "https://picsum.photos/200/150?random=8",
            width: 200,
            height: 150
        )
        
        ImageCellView(
            title: "Mountain View",
            subtitle: "Hiking adventure",
            imageURLString: "https://picsum.photos/200/150?random=9",
            width: 200,
            height: 150
        )
    }
    .padding()
}
