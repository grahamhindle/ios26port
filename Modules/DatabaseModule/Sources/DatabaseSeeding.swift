import Dependencies
import Foundation
import IssueReporting
import OSLog
import SharingGRDB
import SwiftUI

// MARK: - Constants
private let baseDate = Date(timeIntervalSince1970: 1234567890)

#if DEBUG
  extension Database {
    func seedSampleData() throws {
      try seedUserSampleData()
      try seedAvatarSampleData()
    }

    func seedAvatarTestData() throws {
      //need user and Avatar
      try seedUserSampleData()
      try seedAvatarSampleData()
    }
    
    func seedUserTestData() throws {
      // Minimal test data for unit tests
      try self.seed {
        User(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          name: "Test User",
          dateOfBirth: baseDate.addingTimeInterval(-86400 * 365 * 25),
          email: "test@example.com",
          dateCreated: baseDate,
          lastSignedInDate: baseDate.addingTimeInterval(-900),
          authId: "test|test_user_001",
          isAuthenticated: true,
          providerID: "test",
          membershipStatus: .free,
          authorizationStatus: .authorized,
          themeColorHex: 0xE74C_3CFF,
          profileCreatedAt: baseDate,
          profileUpdatedAt: nil
        )
      }
    }
    
    func seedUserSampleData() throws {
      // Full sample data for simulator/live app
      try self.seed {
        User(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          name: "John Doe",
          dateOfBirth: baseDate.addingTimeInterval(-86400 * 365 * 30),
          email: "john@example.com",
          dateCreated: baseDate,
          lastSignedInDate: baseDate.addingTimeInterval(-900),
          authId: "auth0|686e9c718d2bc0b5367bf1bd",
          isAuthenticated: true,
          providerID: "password",
          membershipStatus: .free,
          authorizationStatus: .authorized,
          themeColorHex: 0xE74C_3CFF,
          profileCreatedAt: baseDate,
          profileUpdatedAt: nil
        )
        User(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          name: "Jane Smith",
          dateOfBirth: baseDate.addingTimeInterval(-86400 * 365 * 25),
          email: "jane@example.com",
          dateCreated: baseDate.addingTimeInterval(-3600),
          lastSignedInDate: baseDate.addingTimeInterval(-1800),
          authId: "google-oauth2|123456789012345",
          isAuthenticated: true,
          providerID: "google-oauth2",
          membershipStatus: .premium,
          authorizationStatus: .authorized,
          themeColorHex: 0x3498_DBFF,
          profileCreatedAt: baseDate.addingTimeInterval(-3600),
          profileUpdatedAt: nil
        )
        User(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
          name: "Bob Wilson",
          dateOfBirth: nil,
          email: nil,
          dateCreated: baseDate.addingTimeInterval(-7200),
          lastSignedInDate: nil,
          authId: "guest|guest_user_temp",
          isAuthenticated: false,
          providerID: "guest",
          membershipStatus: .free,
          authorizationStatus: .guest,
          themeColorHex: 0x95A5_A6FF,
          profileCreatedAt: baseDate.addingTimeInterval(-7200),
          profileUpdatedAt: nil
        )
      }
    }
    func seedAvatarSampleData() throws {
      // Avatars
      try self.seed {
        Avatar(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          avatarId: "avatar_business_001",
          name: "Business Professional",
          subtitle: "Expert business consultant",
          promptCategory: .business,
          promptCharacterType: .consultant,
          promptCharacterMood: .professional,
          profileImageName: "avatar_business_man",
          profileImageURL: "https://picsum.photos/seed/business/400/400",
          thumbnailURL: "https://picsum.photos/seed/business-thumb/200/200",
          generatedPrompt: """
            You are an expert business consultant with a helpful personality, working from a city office.

            Please provide business insights and recommendations for:
            - Strategy
            - Analysis
            - Planning
            - Implementation

            **User Request**: Please help me with this business task
            **Context**: General business assistance needed
            **Code**: No code provided
            **Specific Requirements**: None specified

            Please provide a comprehensive response with:
            1. Clear explanations
            2. Code examples where applicable
            3. Best practices
            4. Step-by-step guidance if needed
            """,
          userId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          isPublic: true,
          dateCreated: baseDate.addingTimeInterval(-86400),
          dateModified: baseDate.addingTimeInterval(-3600)
        )
        Avatar(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          avatarId: "avatar_creative_002",
          name: "Creative Mentor",
          subtitle: "Design and creativity expert",
          promptCategory: .design,
          promptCharacterType: .mentor,
          promptCharacterMood: .creative,
          profileImageName: "avatar_creative_woman",
          profileImageURL: "https://picsum.photos/seed/creative/400/400",
          thumbnailURL: "https://picsum.photos/seed/creative-thumb/200/200",
          generatedPrompt: """
            You are an expert mentor with a creative personality, working from a museum.

            Please help me with design including:
            - Principles
            - Best practices
            - Recommendations
            - Creative solutions

            **User Request**: Please help me with this creative task
            **Context**: General creative assistance needed
            **Code**: No code provided
            **Specific Requirements**: None specified

            Please provide a comprehensive response with:
            1. Clear explanations
            2. Code examples where applicable
            3. Best practices
            4. Step-by-step guidance if needed
            """,
          userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          isPublic: true,
          dateCreated: baseDate.addingTimeInterval(-72000),
          dateModified: baseDate.addingTimeInterval(-1800)
        )
        Avatar(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
          avatarId: "avatar_casual_003",
          name: "Friendly Helper",
          subtitle: "Your casual assistant",
          promptCategory: .general,
          promptCharacterType: .enthusiast,
          promptCharacterMood: .friendly,
          profileImageName: "avatar_casual_person",
          profileImageURL: "https://picsum.photos/seed/casual/400/400",
          thumbnailURL: "https://picsum.photos/seed/casual-thumb/200/200",
          generatedPrompt: """
            You are a friendly and enthusiastic assistant with a casual personality, working from a cozy coffee shop.

            Please help me with general tasks including:
            - Daily planning
            - Problem solving
            - Learning new skills
            - Creative brainstorming

            **User Request**: Please help me with this general task
            **Context**: General assistance needed
            **Code**: No code provided
            **Specific Requirements**: None specified

            Please provide a comprehensive response with:
            1. Clear explanations
            2. Practical examples where applicable
            3. Encouraging guidance
            4. Step-by-step help if needed
            """,
          userId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          isPublic: false,
          dateCreated: baseDate.addingTimeInterval(-43200),
          dateModified: baseDate.addingTimeInterval(-900)
        )
        Avatar(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
          avatarId: "avatar_casual_004",
          name: "Friendly Master",
          subtitle: "Your creative assistant",
          promptCategory: .design,
          promptCharacterType: .enthusiast,
          promptCharacterMood: .friendly,
          profileImageName: "avatar_friendly_person",
          profileImageURL: "https://picsum.photos/seed/casual/400/400",
          thumbnailURL: "https://picsum.photos/seed/casual-thumb/200/200",
          generatedPrompt: """
            You are an expert creative mentor with a friendly personality, working from an inspiring art studio.

            Please help me with creative projects including:
            - Design concepts
            - Artistic techniques
            - Creative problem solving
            - Inspiration and motivation

            **User Request**: Please help me with this creative project
            **Context**: Creative assistance needed
            **Code**: No code provided
            **Specific Requirements**: None specified

            Please provide a comprehensive response with:
            1. Creative insights
            2. Visual examples where applicable
            3. Artistic best practices
            4. Step-by-step creative guidance if needed
            """,
          userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          isPublic: false,
          dateCreated: baseDate.addingTimeInterval(-43200),
          dateModified: baseDate.addingTimeInterval(-900)
        )
      }
    }
  }
#endif