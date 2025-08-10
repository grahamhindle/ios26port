import SwiftUI

// MARK: - User Grid Cell

public struct LargeGridCell: View {
    public let color: Color
    public let count: Int?
    public let iconName: String
    public let title: String
    public let action: () -> Void
    
    public init(
        color: Color,
        count: Int?,
        iconName: String,
        title: String,
        action: @escaping () -> Void
    ) {
        self.color = color
        self.count = count
        self.iconName = iconName
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: iconName)
                        .font(.title)
                        .bold()
                        .foregroundStyle(color)
                        .background(
                            Color.white.clipShape(Circle()).padding(4)
                        )
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .bold()
                        .padding(.leading, 4)
                }
                Spacer()
                if let count {
                    Text("\(count)")
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                        .foregroundStyle(Color(.label))
                }
            }
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }
}

// MARK: - Membership Grid Cell

public struct MediumGridCell: View {
    public let color: Color
    public let count: Int?
    public let iconName: String
    public let title: String
    public let action: () -> Void
    
    public init(
        color: Color,
        count: Int?,
        iconName: String,
        title: String,
        action: @escaping () -> Void
    ) {
        self.color = color
        self.count = count
        self.iconName = iconName
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(color)
                    .frame(height: 24)
                
                if let count {
                    Text("\(count)")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .bold()
                        .foregroundStyle(Color(.label))
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)
        }
    }
}

public struct SmallGridCell: View {
    public let color: Color
    public let count: Int?
    public let iconName: String
    public let title: String
    public let action: () -> Void
    
    public init(
        color: Color,
        count: Int?,
        iconName: String,
        title: String,
        action: @escaping () -> Void
    ) {
        self.color = color
        self.count = count
        self.iconName = iconName
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(color)
                    .frame(height: 8)
                
                if let count {
                    Text("\(count)")
                        .font(SharedFonts.title3)
                        .fontDesign(.rounded)
                        .bold()
                        .foregroundStyle(Color(.label))
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 4))
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}

// MARK: - Previews

#Preview("User Grid Cells") {
    VStack(spacing: 16) {
        // Users Group - 2 rows of 2 cells each
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                LargeGridCell(
                    color: .green,
                    count: 142,
                    iconName: "person.3.fill",
                    title: "All Users"
                ) { }
                
                LargeGridCell(
                    color: .blue,
                    count: 23,
                    iconName: "calendar.circle.fill",
                    title: "Today"
                ) { }
            }
            
            HStack(spacing: 8) {
                LargeGridCell(
                    color: .orange,
                    count: 89,
                    iconName: "checkmark.shield.fill",
                    title: "Authenticated"
                ) { }
                
                LargeGridCell(
                    color: .gray,
                    count: 53,
                    iconName: "person.crop.circle.dashed",
                    title: "Guests"
                ) { }
            }
        }
        
        // Membership Status Group
        VStack(spacing: 8) {
            Text("Membership Status")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            
            HStack(spacing: 6) {
                MediumGridCell(
                    color: .green,
                    count: 67,
                    iconName: "dollarsign.circle",
                    title: "Free"
                ) { }
                
                MediumGridCell(
                    color: .blue,
                    count: 42,
                    iconName: "crown.fill",
                    title: "Premium"
                ) { }
                
                MediumGridCell(
                    color: .purple,
                    count: 33,
                    iconName: "building.2.fill",
                    title: "Enterprise"
                ) { }
            }
        }
    }
    .padding()
}