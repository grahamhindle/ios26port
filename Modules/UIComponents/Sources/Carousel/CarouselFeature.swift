import SharedResources
import SwiftUI

// MARK: - Simple Carousel View

// public struct CarouselView<Item: Identifiable>: View {
//     let items: [Item]
//     let itemSpacing: CGFloat
//     let itemWidth: CGFloat
//     let itemHeight: CGFloat
//     let showIndicators: Bool
//     let content: (Item) -> AnyView

//     @State private var currentIndex: Int = 0

//     public init(
//         items: [Item],
//         itemSpacing: CGFloat = 16,
//         itemWidth: CGFloat = 280,
//         itemHeight: CGFloat = 200,
//         showIndicators: Bool = true,
//         @ViewBuilder content: @escaping (Item) -> some View
//     ) {
//         self.items = items
//         self.itemSpacing = itemSpacing
//         self.itemWidth = itemWidth
//         self.itemHeight = itemHeight
//         self.showIndicators = showIndicators
//         self.content = { item in AnyView(content(item)) }
//     }

//     public var body: some View {
//         VStack(spacing: 16) {
//             if items.isEmpty {
//                 EmptyCarouselView()
//             } else {
//                 if #available(iOS 17, *) {
//                     ScrollView(.horizontal, showsIndicators: true) {
//                         LazyHStack(spacing: itemSpacing) {
//                             ForEach(items) { item in
//                                 content(item)
//                                     .frame(width: itemWidth, height: itemHeight)
//                                     .id(item.id)
//                                     .containerRelativeFrame(.horizontal)
//                             }
//                         }
//                         .scrollTargetLayout()
//                     }
//                     .scrollTargetBehavior(.paging)
//                     .scrollIndicators(.visible)
//                     .contentMargins(.horizontal, max(0, itemSpacing / 2))
//                 } else {
//                     ScrollView(.horizontal, showsIndicators: true) {
//                         LazyHStack(spacing: itemSpacing) {
//                             ForEach(items) { item in
//                                 content(item)
//                                     .frame(width: itemWidth, height: itemHeight)
//                             }
//                         }
//                         .padding(.horizontal, itemSpacing / 2)
//                     }
//                 }

//                 if showIndicators && items.count > 1 {
//                     CarouselIndicators(currentIndex: $currentIndex, totalItems: items.count)
//                 }
//             }
//         }
//     }
// }

// MARK: - Carousel Indicators

public struct CarouselView<Content: View, T: Hashable>: View {
    public init(items: [T], content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
    }

    var items: [T]
    @ViewBuilder var content: (T) -> Content

    @State private var selection: T?

    public var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .scrollTransition(.interactive.threshold(.visible(0.95)),
                                              transition: { content, phase in
                                                  content
                                                      .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                              })
                            .containerRelativeFrame(.horizontal, alignment: .center)
                            .id(item)
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .onChange(of: items.count) { _, _ in
                updateSelectionIfNeeded()
            }
            .onAppear {
                updateSelectionIfNeeded()
            }

            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(item == selection ? SharedColors.accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }

    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

public struct CarouselIndicators: View {
    @Binding var currentIndex: Int
    let totalItems: Int

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< totalItems, id: \.self) { index in
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
        ZStack(alignment: .bottomLeading) {
            // Image
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImageView(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
            }

            // Gradient + text overlay
            LinearGradient(colors: [.clear, .black.opacity(0.6)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 70)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .compositingGroup()
        .shadow(radius: 2)
    }
}

// MARK: - Preview
