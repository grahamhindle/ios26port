import SwiftUI

public struct ImageURLPicker: View {
    @Binding var selectedURL: String?
    let title: String

    @State private var urlInput = ""
    @Environment(\.dismiss) private var dismiss

    // Some sample URLs for quick selection
    private let sampleURLs = [
        "https://picsum.photos/400/400?random=1",
        "https://picsum.photos/400/400?random=2",
        "https://picsum.photos/400/400?random=3",
        "https://picsum.photos/400/400?random=4",
        "https://picsum.photos/400/400?random=5",
        "https://picsum.photos/400/400?random=6"
    ]

    public init(selectedURL: Binding<String?>, title: String) {
        _selectedURL = selectedURL
        self.title = title
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("Enter URL") {
                    TextField("Image URL", text: $urlInput)
                        .textContentType(.URL)
                        .disableAutocorrection(true)

                    if !urlInput.isEmpty, let url = URL(string: urlInput) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .frame(height: 100)
                        }
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Section("Quick Select") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(sampleURLs, id: \.self) { urlString in
                            Button {
                                urlInput = urlString
                            } label: {
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(urlInput == urlString ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                if selectedURL != nil {
                    Section {
                        Button("Remove Current Image", role: .destructive) {
                            selectedURL = nil
                            urlInput = ""
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(title)
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Select") {
                            selectedURL = urlInput.isEmpty ? nil : urlInput
                            dismiss()
                        }
                        .disabled(urlInput.isEmpty)
                    }
                }
        }
        .onAppear {
            urlInput = selectedURL ?? ""
        }
    }
}

struct ImageURLPicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageURLPicker(
            selectedURL: .constant("https://picsum.photos/400/400"),
            title: "Select Image"
        )
    }
}
