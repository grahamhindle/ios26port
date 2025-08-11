import SwiftUI

// MARK: - Grid Cell Size Configuration

public enum GridCellSize {
    case large
    case medium
    case small

    var iconFont: Font {
        switch self {
        case .large: .title
        case .medium: .title2
        case .small: .title3
        }
    }

    var countFont: Font {
        switch self {
        case .large: .title
        case .medium: .title2
        case .small: .title3
        }
    }

    var titleFont: Font {
        switch self {
        case .large: .headline
        case .medium, .small: .caption
        }
    }

    var spacing: CGFloat {
        switch self {
        case .large: 8
        case .medium: 6
        case .small: 4
        }
    }

    var padding: EdgeInsets {
        switch self {
        case .large: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .medium: EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
        case .small: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 4)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: 10
        case .medium, .small: 8
        }
    }

    var iconFrameHeight: CGFloat? {
        switch self {
        case .large: nil
        case .medium: 24
        case .small: 8
        }
    }

    var usesHorizontalLayout: Bool {
        switch self {
        case .large: true
        case .medium, .small: false
        }
    }

    var hasIconBackground: Bool {
        switch self {
        case .large: true
        case .medium, .small: false
        }
    }

    var hasBorder: Bool {
        switch self {
        case .small: true
        case .large, .medium: false
        }
    }

    var titleColor: Color {
        switch self {
        case .large: .gray
        case .medium, .small: .secondary
        }
    }
}

// MARK: - Unified Grid Cell

public struct GridCell: View {
    public let size: GridCellSize
    public let color: Color
    public let count: Int?
    public let iconName: String
    public let title: String
    public let action: () -> ()

    public init(
        size: GridCellSize,
        color: Color,
        count: Int? = nil,
        iconName: String,
        title: String,
        action: @escaping () -> ()
    ) {
        self.size = size
        self.color = color
        self.count = count
        self.iconName = iconName
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if size.usesHorizontalLayout {
                    horizontalLayout
                } else {
                    verticalLayout
                }
            }
            .padding(size.padding)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(size.cornerRadius)
            .overlay(
                size.hasBorder ? 
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(color, lineWidth: 2) : nil
            )
        }
    }

    private var horizontalLayout: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: size.spacing) {
                iconView
                titleView
                    .padding(.leading, 4)
            }
            Spacer()
            countView
        }
    }

    private var verticalLayout: some View {
        VStack(spacing: size.spacing) {
            iconView
            countView
            titleView
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var iconView: some View {
        Group {
            if size.hasIconBackground {
                Image(systemName: iconName)
                    .font(size.iconFont)
                    .bold()
                    .foregroundStyle(color)
                    .background(
                        Color.white.clipShape(Circle()).padding(4)
                    )
            } else {
                Image(systemName: iconName)
                    .font(size.iconFont)
                    .bold()
                    .foregroundStyle(color)
                    .frame(height: size.iconFrameHeight)
            }
        }
    }

    private var countView: some View {
        Group {
            if let count {
                Text("\(count)")
                    .font(size.countFont)
                    .fontDesign(.rounded)
                    .bold()
                    .foregroundStyle(Color(.label))
            }
        }
    }

    private var titleView: some View {
        Text(title)
            .font(size.titleFont)
            .foregroundStyle(size.titleColor)
            .bold()
    }
}

// MARK: - Previews

#Preview("Grid Cells") {
    VStack(spacing: 16) {
        // Large Grid Cells - 2 rows of 2 cells each
        VStack(spacing: 8) {
            Text("Large Grid Cells")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                GridCell(
                    size: .large,
                    color: .green,
                    count: 142,
                    iconName: "person.3.fill",
                    title: "All Users"
                ) {}

                GridCell(
                    size: .large,
                    color: .blue,
                    count: 23,
                    iconName: "calendar.circle.fill",
                    title: "Today"
                ) {}
            }

            HStack(spacing: 8) {
                GridCell(
                    size: .large,
                    color: .orange,
                    count: 89,
                    iconName: "checkmark.shield.fill",
                    title: "Authenticated"
                ) {}

                GridCell(
                    size: .large,
                    color: .gray,
                    count: 53,
                    iconName: "person.crop.circle.dashed",
                    title: "Guests"
                ) {}
            }
        }

        // Medium Grid Cells
        VStack(spacing: 8) {
            Text("Medium Grid Cells")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                GridCell(
                    size: .medium,
                    color: .green,
                    count: 67,
                    iconName: "dollarsign.circle",
                    title: "Free"
                ) {}

                GridCell(
                    size: .medium,
                    color: .blue,
                    count: 42,
                    iconName: "crown.fill",
                    title: "Premium"
                ) {}

                GridCell(
                    size: .medium,
                    color: .purple,
                    count: 33,
                    iconName: "building.2.fill",
                    title: "Enterprise"
                ) {}
            }
        }

        // Small Grid Cells
        VStack(spacing: 8) {
            Text("Small Grid Cells")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                GridCell(
                    size: .small,
                    color: .red,
                    count: 12,
                    iconName: "star.fill",
                    title: "Favorites"
                ) {}

                GridCell(
                    size: .small,
                    color: .blue,
                    count: 8,
                    iconName: "heart.fill",
                    title: "Liked"
                ) {}

                GridCell(
                    size: .small,
                    color: .purple,
                    count: 5,
                    iconName: "bookmark.fill",
                    title: "Saved"
                ) {}

                GridCell(
                    size: .small,
                    color: .orange,
                    iconName: "plus.circle.fill",
                    title: "Add New"
                ) {}
            }
        }
    }
    .padding()
}
