import XCTest
@testable import Chat

final class ExampleTest: XCTestCase {
    
    func testBasicFunctionality() {
        // Simple test to verify the test target works
        XCTAssertTrue(true, "Basic test should pass")
    }
    
    func testFrameworkImport() {
        // Test that we can import the Chat framework
        // This will fail if there are linking issues
        XCTAssertNotNil(ChatFeature.self, "ChatFeature should be accessible")
    }
}



