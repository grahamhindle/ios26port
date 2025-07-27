import SwiftUI
import SharedResources

// MARK: - Simple Carousel View

public struct CarouselView<Item: Identifiable>: View {
    let items: [Item]
    let itemSpacing: CGFloat
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let showIndicators: Bool
    let content: (Item) -> AnyView
    
    @State private var currentIndex: Int = 0
    
    public init(
        items: [Item],
        itemSpacing: CGFloat = 16,
        itemWidth: CGFloat = 280,
        itemHeight: CGFloat = 200,
        showIndicators: Bool = true,
        @ViewBuilder content: @escaping (Item) -> some View
    ) {
        self.items = items
        self.itemSpacing = itemSpacing
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.showIndicators = showIndicators
        self.content = { item in AnyView(content(item)) }
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            if items.isEmpty {
                EmptyCarouselView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(items) { item in
                            content(item)
                                .frame(width: itemWidth, height: itemHeight)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: itemSpacing)
                        }
                    }
                    .padding(.horizontal, itemSpacing)
                }
                .scrollTargetBehavior(.viewAligned)
                
                if showIndicators && items.count > 1 {
                    CarouselIndicators(
                        currentIndex: $currentIndex,
                        totalItems: items.count
                    )
                }
            }
        }
    }
}

// MARK: - Carousel Indicators

public struct CarouselIndicators: View {
    @Binding var currentIndex: Int
    let totalItems: Int
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalItems, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .onTapGesture {
                        currentIndex = index
                    }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Empty State

public struct EmptyCarouselView: View {
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No items to display")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
}

// MARK: - Convenience Card Views

public struct CarouselCard: View {
    let title: String
    let subtitle: String?
    let imageURL: String?
    let cornerRadius: CGFloat
    
    public init(
        title: String,
        subtitle: String? = nil,
        imageURL: String? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImageView(
                    url: url,
                    height: 120,
                    cornerRadius: cornerRadius,
                    contentMode: .fill,
                    placeholderImage: "photo"
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(radius: 2)
    }
}

// MARK: - Preview

#Preview {
    struct SampleItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let imageURL: String?
    }
    
    let sampleItems = [
        SampleItem(title: "Item 1", subtitle: "Description 1", imageURL: "https://picsum.photos/300/200?random=1"),
        SampleItem(title: "Item 2", subtitle: "Description 2", imageURL: "https://picsum.photos/300/200?random=2"),
        SampleItem(title: "Item 3", subtitle: "Description 3", imageURL: "https://picsum.photos/300/200?random=3")
    ]
    
    return CarouselView(items: sampleItems) { item in
        CarouselCard(
            title: item.title,
            subtitle: item.subtitle,
            imageURL: item.imageURL
        )
    }
    .padding()
}
