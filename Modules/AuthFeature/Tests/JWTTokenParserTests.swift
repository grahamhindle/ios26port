//
//  JWTTokenParserTests.swift
//  AuthFeatureTests
//
//  Created by Claude Code on 12/08/25.
//

@testable import AuthFeature
import Testing

@Suite("JWT Token Parser Tests")
struct JWTTokenParserTests {
    
    @Test("AuthError cases")
    func authErrorCases() async {
        let missingUserIdError = AuthError.missingUserId
        #expect(missingUserIdError.errorDescription == "Authentication succeeded but user ID is missing")
    }
    
    @Test("extractUserIdFromToken with nil token")
    func extractUserIdFromNilToken() async {
        let result = extractUserIdFromToken(nil)
        #expect(result == nil)
    }
    
    @Test("extractUserIdFromToken with empty token")
    func extractUserIdFromEmptyToken() async {
        let result = extractUserIdFromToken("")
        #expect(result == nil)
    }
    
    @Test("extractUserIdFromToken with invalid token")
    func extractUserIdFromInvalidToken() async {
        let result = extractUserIdFromToken("invalid.token.string")
        #expect(result == nil)
    }
    
    @Test("extractProviderFromToken with nil token")
    func extractProviderFromNilToken() async {
        let result = extractProviderFromToken(nil)
        #expect(result == nil)
    }
    
    @Test("extractProviderFromToken with empty token")
    func extractProviderFromEmptyToken() async {
        let result = extractProviderFromToken("")
        #expect(result == nil)
    }
    
    @Test("extractProviderFromToken with invalid token")
    func extractProviderFromInvalidToken() async {
        let result = extractProviderFromToken("invalid.token.string")
        #expect(result == nil)
    }
    
    @Test("extractEmailFromToken with nil token")
    func extractEmailFromNilToken() async {
        let result = extractEmailFromToken(nil)
        #expect(result == nil)
    }
    
    @Test("extractEmailFromToken with empty token")
    func extractEmailFromEmptyToken() async {
        let result = extractEmailFromToken("")
        #expect(result == nil)
    }
    
    @Test("extractEmailFromToken with invalid token")
    func extractEmailFromInvalidToken() async {
        let result = extractEmailFromToken("invalid.token.string")
        #expect(result == nil)
    }
}