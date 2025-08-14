import Dependencies
import Foundation
import IssueReporting
import OSLog
import SharingGRDB
import SwiftUI

#if DEBUG
extension Database {
    func seedSampleData() throws {

        // Use fixed UUIDs for consistent testing/preview behavior
        let userIDs = (0...2).map { _ in UUID() }
        let avatarIDs = (0...10).map { _ in UUID() }


        try self.seed {
            User(
                id: userIDs[0],
                name: "John Doe",
                dateOfBirth: Date().addingTimeInterval(-86400 * 365 * 30),
                email: "john@example.com",
                dateCreated: Date(),
                lastSignedInDate: Date().addingTimeInterval(-900),
                authId: "auth0|686e9c718d2bc0b5367bf1bd",
                isAuthenticated: true,
                providerID: "password",
                membershipStatus: .free,
                authorizationStatus: .authorized,
                themeColorHex: 0xE74C_3CFF,
                profileCreatedAt: Date(),
                profileUpdatedAt: nil
            )
            User(
                id: userIDs[1],
                name: "Jane Smith",
                dateOfBirth: Date().addingTimeInterval(-86400 * 365 * 25),
                email: "jane@example.com",
                dateCreated: Date().addingTimeInterval(-3600),
                lastSignedInDate: Date().addingTimeInterval(-1800),
                authId: "google-oauth2|123456789012345",
                isAuthenticated: true,
                providerID: "google-oauth2",
                membershipStatus: .premium,
                authorizationStatus: .authorized,
                themeColorHex: 0x3498_DBFF,
                profileCreatedAt: Date().addingTimeInterval(-3600),
                profileUpdatedAt: nil
            )
            User(
                id: userIDs[2],
                name: "Bob Wilson",
                dateOfBirth: nil,
                email: nil,
                dateCreated: Date().addingTimeInterval(-7200),
                lastSignedInDate: nil,
                authId: "guest|guest_user_temp",
                isAuthenticated: false,
                providerID: "guest",
                membershipStatus: .free,
                authorizationStatus: .guest,
                themeColorHex: 0x95A5_A6FF,
                profileCreatedAt: Date().addingTimeInterval(-7200),
                profileUpdatedAt: nil
            )
            // Avatars
            Avatar(
                id: avatarIDs[0],
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


                userId: userIDs[0],
                isPublic: true,
                dateCreated: Date().addingTimeInterval(-86400),
                dateModified: Date().addingTimeInterval(-3600)
            )
            Avatar(
                id: avatarIDs[1],
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
                userId: userIDs[1],
                isPublic: true,
                dateCreated: Date().addingTimeInterval(-72000),
                dateModified: Date().addingTimeInterval(-1800)
            )
            Avatar(
                id: avatarIDs[2],
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
                userId: userIDs[2],
                isPublic: false,
                dateCreated: Date().addingTimeInterval(-43200),
                dateModified: Date().addingTimeInterval(-900)
            )
            Avatar(
                id: avatarIDs[3],
                avatarId: "avatar_casual_004",
                name: "Friendly Master",
                subtitle: "Your creative assistant",
                promptCategory: .design,
                promptCharacterType: .enthusiast,
                promptCharacterMood: .friendly,
                profileImageName: "avatar_friendly_person",
                profileImageURL: "https://picsum.photos/seed/casual/400/400",
                thumbnailURL: "https://picsum.photos/seed/casual-thumb/200/200",
                generatedPrompt:                """
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
                userId: userIDs[0],
                isPublic: false,
                dateCreated: Date().addingTimeInterval(-43200),
                dateModified: Date().addingTimeInterval(-900)
            )

        }
    }
}
#endif

