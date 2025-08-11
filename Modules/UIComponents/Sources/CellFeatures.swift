import SwiftUI

// public struct HeroCellView: View {
//     var imageURLString: String?
//     var backgroundColor: Color?
//     var title: String?
//     var subtitle: String?
//     var callToAction: String?

//     public init(
//         title: String? = nil,
//         subtitle: String? = nil,
//         imageURLString: String? = nil,
//         callToAction: String? = nil,
//         backgroundColor: Color? = nil
//     ) {
//         self.title = title
//         self.subtitle = subtitle
//         self.imageURLString = imageURLString
//         self.callToAction = callToAction
//         self.backgroundColor = backgroundColor
//     }

//     public var body: some View {
//         ZStack(alignment: .bottomLeading) {
//             AsyncImageView(
//                 heroURL: URL(string: imageURLString ?? ""),
//                 height: 200
//             )
//             if let backgroundColor = backgroundColor {
//                 backgroundColor
//             }
//             VStack(alignment: .leading, spacing: 8) {
//                 if let title = title {
//                     Text(title)
//                         .font(.headline)
//                         .fontWeight(.bold)
//                         .foregroundColor(.white)
//                 }
//                 if let subtitle = subtitle {
//                     Text(subtitle)
//                         .font(.subheadline)
//                         .foregroundColor(.white.opacity(0.9))
//                 }
//                 if let callToAction = callToAction {
//                     Text(callToAction)
//                         .font(.caption)
//                         .padding(.horizontal, 12)
//                         .padding(.vertical, 6)
//                         .background(Color.white.opacity(0.2))
//                         .foregroundColor(.white)
//                         .clipShape(Capsule())
//                 }
//             }
//             .padding(16)
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .background(
//                 LinearGradient(
//                     gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
//                     startPoint: .top,
//                     endPoint: .bottom
//                 )
//             )
//         }
//         .clipShape(RoundedRectangle(cornerRadius: 16))
//     }
// }

public struct HeroCellView: View {

    var title: String? = "This is some title"
    var subtitle: String? = "This is some subtitle"
    var imageName: String? = "https://picsum.photos/200/300"
    public init(title: String? = nil, subtitle: String? = nil, imageName: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }

    public var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 200)
            .background(
                Group {
                    if let imageName, let url = URL(string: imageName) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(ProgressView())
                        }
                    } else {
                        Rectangle().fill(Color.red)
                    }
                }
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

    }
}
