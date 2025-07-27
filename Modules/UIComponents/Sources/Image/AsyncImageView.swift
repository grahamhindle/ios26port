import SwiftUI
import SharedResources

// MARK: - Simple Reliable AsyncImageView

public struct AsyncImageView: View {
    private let url: URL?
    private let width: CGFloat?
    private let height: CGFloat?
    private let cornerRadius: CGFloat
    private let contentMode: ContentMode
    private let placeholderImage: String?
    private let placeholderColor: Color
    
    public init(
        url: URL?,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 0,
        contentMode: ContentMode = .fill,
        placeholderImage: String? = nil,
        placeholderColor: Color = Color.gray.opacity(0.3)
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.contentMode = contentMode
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
    }
    
    public var body: some View {

        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            Rectangle()
                .foregroundColor(.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.title)
                )
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                )
        }
        //.frame(width: 40, height: 40)
    }


    
    @ViewBuilder
    private var placeholderView: some View {
        if let placeholderImage = placeholderImage {
            Image(systemName: placeholderImage)
                .font(.title)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(placeholderColor)
        } else {
            Rectangle()
                .fill(placeholderColor)
                .overlay(
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.gray)
                )
        }
    }
}

// MARK: - Convenience Initializers

public extension AsyncImageView {
    // Avatar image initializer
    init(
        avatarURL: URL?,
        size: CGFloat = 50,
        cornerRadius: CGFloat? = nil
    ) {
        self.init(
            url: avatarURL,
            width: size,
            height: size,
            cornerRadius: cornerRadius ?? size / 2, // Default to circle
            contentMode: .fill,
            placeholderImage: "person.fill",
            placeholderColor: Color.gray.opacity(0.2)
        )
    }
    
    // Hero image initializer
    init(
        heroURL: URL?,
        height: CGFloat = 200,
        cornerRadius: CGFloat = 12
    ) {
        self.init(
            url: heroURL,
            width: nil,
            height: height,
            cornerRadius: cornerRadius,
            contentMode: .fill,
            placeholderImage: "photo.on.rectangle",
            placeholderColor: Color.gray.opacity(0.2)
        )
    }
    
    // Thumbnail image initializer
    init(
        thumbnailURL: URL?,
        width: CGFloat = 100,
        height: CGFloat = 100,
        cornerRadius: CGFloat = 8
    ) {
        self.init(
            url: thumbnailURL,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            contentMode: .fill,
            placeholderImage: "photo",
            placeholderColor: Color.gray.opacity(0.2)
        )
    }
}

// MARK: - Helper Views

public struct WelcomeImageView: View {
    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat
    
    public init(
        width: CGFloat? = nil,
        height: CGFloat = 200,
        cornerRadius: CGFloat = 12
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        Image(systemName: SharedImages.placeholder)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .foregroundColor(.gray.opacity(0.6))
            .background(Color.gray.opacity(0.2))
    }
}

// MARK: - URL Generation Helpers (Simplified)

public enum ImageURLGenerator {
    // Reliable test images
    public static let reliableTestImages: [URL] = [
        "https://picsum.photos/600/400?random=1",
        "https://picsum.photos/600/400?random=2",
        "https://picsum.photos/600/400?random=3",
        "https://picsum.photos/600/400?random=4",
        "https://picsum.photos/600/400?random=5"
    ].compactMap { URL(string: $0) }
    
    // Generate a random Picsum image
    public static func randomPicsum(
        width: Int = 600,
        height: Int = 400
    ) -> URL? {
        let randomId = Int.random(in: 1...1000)
        return URL(string: "https://picsum.photos/\(width)/\(height)?random=\(randomId)")
    }
    
    // Generate a placeholder image
    public static func placeholder(
        width: Int = 400,
        height: Int = 300,
        text: String = "Placeholder"
    ) -> URL? {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Placeholder"
        return URL(string: "https://via.placeholder.com/\(width)x\(height)/CCCCCC/666666?text=\(encodedText)")
    }
    
    // Get next reliable test image
    public static func nextReliableImage() -> URL? {
        return reliableTestImages.randomElement()
    }
}

// MARK: - Preview

#Preview("AsyncImageView Examples") {
    ScrollView {
        VStack(spacing: 20) {
            Text("AsyncImageView Examples")
                .font(.title)
                .padding()
            
            // Avatar examples
            HStack(spacing: 16) {
                AsyncImageView(
                    avatarURL: URL(string: "https://picsum.photos/100/100?random=1"),
                    size: 60
                )
                
                AsyncImageView(
                    avatarURL: URL(string: "https://picsum.photos/100/100?random=2"),
                    size: 40
                )
                
                AsyncImageView(
                    avatarURL: nil, // Test placeholder
                    size: 50
                )
            }
            
            // Hero image example
            AsyncImageView(
                heroURL: URL(string: "https://picsum.photos/400/200?random=3")
            )
            
            // Thumbnail examples
            HStack(spacing: 16) {
                AsyncImageView(
                    thumbnailURL: URL(string: "https://picsum.photos/150/150?random=4")
                )
                
                AsyncImageView(
                    thumbnailURL: URL(string: "https://picsum.photos/150/150?random=5")
                )
            }
            
            // Custom example
            AsyncImageView(
                url: URL(string: "https://picsum.photos/300/200?random=6"),
                width: 300,
                height: 200,
                cornerRadius: 16,
                contentMode: .fit
            )
            
            // Welcome image
            WelcomeImageView()
        }
        .padding()
    }
}
