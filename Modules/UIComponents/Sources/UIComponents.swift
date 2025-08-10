// MARK: - UIComponents Module

// This module provides reusable UI components

import ComposableArchitecture
import Foundation
import SharedModels
import SharedResources
import SwiftUI

// Import the base cell feature file to make types available
// The public types from BaseCellFeature.swift will be available
// when UIComponents is imported
public struct CategoryCellView: View {
    public init(title: String = "Aliens", imageName: String = "https://picsum.photos/200/300") {
        self.title = title
        self.imageName = imageName
       
    }

    var title: String = "Aliens"
    var imageName: String = "https://picsum.photos/200/300"
    var font: Font = .title2
    var cornerRadius: CGFloat = 16

    public var body: some View {
        AsyncImageView(url: URL(string: imageName)!)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(cornerRadius)
            .overlay(alignment: .bottomLeading, content: {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .padding(16)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .addingGradientBackgroundForText()
            })
            .cornerRadius(cornerRadius)
        
    }
}

#Preview {
    HStack {
        CategoryCellView()
            .frame(width: 300, height: 300)
        CategoryCellView(title: "Androids")
            .frame(width: 150, height: 150)
        CategoryCellView(title: "Robots")
            .frame(width: 200, height: 200)
    }
}
