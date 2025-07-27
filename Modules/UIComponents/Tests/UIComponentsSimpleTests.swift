import Foundation
import Testing
import SwiftUI
@testable import UIComponents

@Suite("UIComponents Core Tests", .serialized)
@MainActor
struct UIComponentsSimpleTests {
    
    // MARK: - ChatCellView Tests
    
    @Test("ChatCellView initialization")
    func chatCellViewInit() {
        let chatCell = ChatCellView(
            headline: "Test Headline",
            subheadline: "Test Subheadline",
            imageURL: "https://example.com/image.jpg",
            hasNewChat: true
        )
        
        #expect(chatCell.headline == "Test Headline")
        #expect(chatCell.subheadline == "Test Subheadline")
        #expect(chatCell.imageURL == "https://example.com/image.jpg")
        #expect(chatCell.hasNewChat == true)
    }
    
    @Test("ChatCellView with optional parameters")
    func chatCellViewWithOptionalParams() {
        let chatCell = ChatCellView(
            headline: "Headline Only",
            subheadline: "",
            imageURL: nil,
            hasNewChat: false
        )
        
        #expect(chatCell.headline == "Headline Only")
        #expect(chatCell.subheadline == "")
        #expect(chatCell.imageURL == nil)
        #expect(chatCell.hasNewChat == false)
    }
    
    // MARK: - AsyncImageView Tests
    
    @Test("AsyncImageView initialization")
    func asyncImageViewInit() {
        let url = URL(string: "https://example.com/image.jpg")
        let asyncImageView = AsyncImageView(
            url: url,
            width: 200,
            height: 150,
            cornerRadius: 8
        )
        
        // View should be created successfully
        _ = asyncImageView
    }
    
    @Test("AsyncImageView with nil URL")
    func asyncImageViewWithNilURL() {
        let asyncImageView = AsyncImageView(
            url: nil,
            width: 100,
            height: 100
        )
        
        // View should be created successfully even with nil URL
        _ = asyncImageView
    }
    
    @Test("WelcomeImageView creation")
    func welcomeImageViewCreation() {
        let welcomeView1 = WelcomeImageView()
        let welcomeView2 = WelcomeImageView(width: 300, height: 250, cornerRadius: 16)
        
        // Views should be created successfully
        _ = welcomeView1
        _ = welcomeView2
    }
    
    // MARK: - ImageURLGenerator Tests
    
    @Test("ImageURLGenerator reliable test images")
    func imageURLGeneratorReliableImages() {
        let reliableImages = ImageURLGenerator.reliableTestImages
        
        #expect(reliableImages.count > 0)
        
        for url in reliableImages {
            #expect(url.scheme == "https")
            // Most should be from picsum.photos or other reliable sources
        }
    }
    
    @Test("ImageURLGenerator random picsum")
    func imageURLGeneratorRandomPicsum() {
        let url1 = ImageURLGenerator.randomPicsum()
        let url2 = ImageURLGenerator.randomPicsum(width: 400, height: 300)
        
        #expect(url1 != nil)
        #expect(url2 != nil)
        
        if let url1 = url1 {
            #expect(url1.absoluteString.contains("picsum.photos"))
        }
        
        if let url2 = url2 {
            #expect(url2.absoluteString.contains("400"))
            #expect(url2.absoluteString.contains("300"))
        }
    }
    
    @Test("ImageURLGenerator placeholder")
    func imageURLGeneratorPlaceholder() {
        let placeholderURL = ImageURLGenerator.placeholder()
        
        #expect(placeholderURL != nil)
        
        if let url = placeholderURL {
            #expect(url.scheme == "https")
        }
    }
    
    @Test("ImageURLGenerator test image")
    func imageURLGeneratorTestImage() {
        let testURL = ImageURLGenerator.testImage()
        
        #expect(testURL != nil)
        
        if let url = testURL {
            #expect(url.absoluteString.contains("dummyimage.com"))
        }
    }
    
    @Test("ImageURLGenerator fromURL")
    func imageURLGeneratorFromURL() {
        let baseURL = URL(string: "https://example.com/image.jpg")!
        
        let modifiedURL1 = ImageURLGenerator.fromURL(baseURL)
        let modifiedURL2 = ImageURLGenerator.fromURL(baseURL, width: 200, height: 150)
        let modifiedURL3 = ImageURLGenerator.fromURL(baseURL, cacheBuster: false)
        
        #expect(modifiedURL1 != nil)
        #expect(modifiedURL2 != nil)
        #expect(modifiedURL3 != nil)
        
        if let url2 = modifiedURL2 {
            #expect(url2.absoluteString.contains("width=200"))
            #expect(url2.absoluteString.contains("height=150"))
        }
    }
    
    // MARK: - ImageCycleActor Tests
    
    @Test("ImageCycleActor next method")
    func imageCycleActorNext() async {
        let testURLs = [
            URL(string: "https://example.com/1.jpg")!,
            URL(string: "https://example.com/2.jpg")!,
            URL(string: "https://example.com/3.jpg")!
        ]
        
        let actor = ImageCycleActor(images: testURLs)
        
        let url1 = await actor.next()
        let url2 = await actor.next()
        let url3 = await actor.next()
        let url4 = await actor.next() // Should cycle back to first
        
        #expect(url1 == testURLs[0])
        #expect(url2 == testURLs[1])
        #expect(url3 == testURLs[2])
        #expect(url4 == testURLs[0]) // Cycling back
    }
    
    @Test("ImageCycleActor with empty array")
    func imageCycleActorEmpty() async {
        let actor = ImageCycleActor(images: [])
        
        let url = await actor.next()
        
        #expect(url == nil)
    }
    
    // MARK: - URL Validation Tests
    
    @Test("Valid image URLs")
    func validImageURLs() {
        let validURLs = [
            "https://picsum.photos/600/600",
            "https://dummyimage.com/400x300",
            "https://httpbin.org/image/png"
        ]
        
        for urlString in validURLs {
            let url = URL(string: urlString)
            #expect(url != nil, "Should create valid URL for: \(urlString)")
            #expect(url?.scheme == "https", "Should use HTTPS")
        }
    }
    
    @Test("Invalid image URLs")
    func invalidImageURLs() {
        let invalidURLs = [
            "",
            "not-a-url",
            "ftp://example.com/image.jpg"
        ]
        
        for urlString in invalidURLs {
            if urlString.isEmpty {
                let url = URL(string: urlString)
                #expect(url != nil) // Empty string creates a valid URL
            } else {
                let url = URL(string: urlString)
                // These should either be nil or not use https
                if let url = url {
                    #expect(url.scheme != "https")
                }
            }
        }
    }
    
    // MARK: - Integration Tests
    
    @Test("ChatCellView with real data")
    func chatCellViewWithRealData() {
        let chatCell = ChatCellView(
            headline: "John Doe",
            subheadline: "Hey, how are you doing?",
            imageURL: "https://picsum.photos/100/100?random=1",
            hasNewChat: true
        )
        
        #expect(chatCell.headline == "John Doe")
        #expect(chatCell.subheadline == "Hey, how are you doing?")
        #expect(chatCell.imageURL?.contains("picsum.photos") == true)
        #expect(chatCell.hasNewChat == true)
    }
    
    @Test("AsyncImageView with reliable test image")
    func asyncImageViewWithReliableImage() async {
        let testURL = await ImageURLGenerator.nextTestImage()
        
        let asyncImageView = AsyncImageView(
            url: testURL,
            width: 200,
            height: 200,
            cornerRadius: 10
        )
        
        // View should be created successfully
        _ = asyncImageView
    }
    
    // MARK: - Edge Cases
    
    @Test("ChatCellView with special characters")
    func chatCellViewWithSpecialCharacters() {
        let chatCell = ChatCellView(
            headline: "🚀 Space User",
            subheadline: "Message with émojis and spëcial chars!",
            imageURL: "https://example.com/测试.jpg",
            hasNewChat: false
        )
        
        #expect(chatCell.headline == "🚀 Space User")
        #expect(chatCell.subheadline == "Message with émojis and spëcial chars!")
        #expect(chatCell.hasNewChat == false)
    }
    
    @Test("AsyncImageView with very large dimensions")
    func asyncImageViewLargeDimensions() {
        let asyncImageView = AsyncImageView(
            url: URL(string: "https://example.com/large.jpg"),
            width: 2000,
            height: 2000,
            cornerRadius: 50
        )
        
        // View should handle large dimensions gracefully
        _ = asyncImageView
    }
    
    @Test("AsyncImageView with zero dimensions")
    func asyncImageViewZeroDimensions() {
        let asyncImageView = AsyncImageView(
            url: URL(string: "https://example.com/zero.jpg"),
            width: 0,
            height: 0,
            cornerRadius: 0
        )
        
        // View should handle zero dimensions gracefully
        _ = asyncImageView
    }
}