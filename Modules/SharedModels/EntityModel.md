# Entity Relationship Model

## Overview
This document describes the entity model for the iOS26Port application, which manages users, profiles, avatars, chats, and messaging.

## Entity Relationship Diagram

```
┌─────────────────┐    1:1    ┌─────────────────┐
│      USER       │◄─────────►│     PROFILE     │
├─────────────────┤           ├─────────────────┤
│ id (PK)         │           │ id (PK)         │
│ name            │           │ userID (FK)     │
│ dateOfBirth     │           │ membershipStatus│
│ email           │           │ themeColorHex   │
│ dateCreated     │           │ authStatus      │
│ lastSignedIn    │           └─────────────────┘
│ authID (FK)     │                    │
└─────────────────┘                    │ M:N
         │                             ▼
         │ 1:1                ┌─────────────────┐
         ▼                    │ PROFILE_AVATAR  │ ◄─┐
┌─────────────────┐           ├─────────────────┤   │
│      AUTH       │           │ id (PK)         │   │ M:N
├─────────────────┤           │ profileID (FK)  │   │
│ id (PK)         │           │ avatarID (FK)   │   │
│ userID (FK)     │           │ isPrimary       │   │
│ authId          │           │ dateAdded       │   │
│ isAuthenticated │           └─────────────────┘   │
│ providerID      │                    │            │
└─────────────────┘                    │            │
         │                             ▼            │
         │ 1:1 (alt)            ┌─────────────────┐  │
         ▼                      │     AVATAR      │◄─┘
┌─────────────────┐             ├─────────────────┤
│      GUEST      │             │ id (PK)         │
├─────────────────┤             │ avatarId        │
│ id (PK)         │             │ name            │
│ userID (FK)     │             │ subtitle        │
│ sessionID       │             │ characterOption │
│ expiresAt       │             │ characterAction │
└─────────────────┘             │ characterLocation│
         │                      │ profileImageName│
         │                      │ profileImageURL │
         └───────────────┐      │ thumbnailURL    │
                         │      │ userId (FK)     │
                         │      │ isPublic        │
                         ▼      │ dateCreated     │
                ┌─────────────────┐ dateModified    │
                │      CHAT       │ └─────────────────┘
                ├─────────────────┤         ▲
                │ id (PK)         │         │
                │ userID (FK)     │─────────┘
                │ avatarID (FK)   │
                │ title           │
                │ createdAt       │
                └─────────────────┘
                         │ 1:M
                         ▼
                ┌─────────────────┐
                │     MESSAGE     │
                ├─────────────────┤
                │ id (PK)         │
                │ chatID (FK)     │
                │ content         │
                │ timestamp       │
                │ isFromUser      │
                └─────────────────┘
                         │ M:N
                         ├─────────────┐
                         ▼             ▼
                ┌─────────────────┐   ┌─────────────────┐
                │   MESSAGE_TAG   │   │  MESSAGE_BADGE  │
                ├─────────────────┤   ├─────────────────┤
                │ id (PK)         │   │ id (PK)         │
                │ messageID (FK)  │   │ messageID (FK)  │
                │ tagID (FK)      │   │ badgeID (FK)    │
                └─────────────────┘   └─────────────────┘
                         │                     │
                         ▼                     ▼
                ┌─────────────────┐   ┌─────────────────┐
                │      TAG        │   │     BADGE       │
                ├─────────────────┤   ├─────────────────┤
                │ id (PK)         │   │ id (PK)         │
                │ name            │   │ name            │
                │ color           │   │ color           │
                │ category        │   │ icon            │
                └─────────────────┘   │ description     │
                                      └─────────────────┘
```

## Key Relationships

### Core Entities
1. **User ↔ Profile**: 1:1 relationship - Each user has one profile
2. **User ↔ Auth/Guest**: 1:1 (mutually exclusive) - User is either authenticated OR guest
3. **Profile ↔ Avatar**: M:N via ProfileAvatar junction table - Profile can use multiple avatars

### Chat System
4. **User ↔ Chat**: 1:M - User can have many chats
5. **Avatar ↔ Chat**: 1:M - Avatar can be in many chats with different users
6. **Chat ↔ Message**: 1:M - Chat contains many messages

### Message Metadata
7. **Message ↔ Tag/Badge**: M:N via junction tables - Messages can have multiple tags and badges

## Entity Details

### User
- **Purpose**: Core identity and basic information
- **Attributes**: name, dateOfBirth, email, timestamps
- **Relationships**: Has one profile, optionally authenticated, can have many chats

### Profile  
- **Purpose**: User preferences and app-specific settings
- **Attributes**: membershipStatus (free/premium/enterprise), authorizationStatus, themeColor
- **Relationships**: Belongs to one user, can use many avatars

### Avatar
- **Purpose**: Shared library of conversational characters
- **Visual**: characterOption, characterAction, characterLocation, image URLs
- **Sharing**: isPublic flag, userId for ownership
- **Reusability**: Multiple users can use the same avatar

### Authentication
- **Auth Record**: For authenticated users with tokens and permissions
- **Guest Record**: For temporary/anonymous users with session management

### Chat System
- **Chat**: Conversation context between a user and an avatar
- **Message**: Individual messages within a chat
- **Tags/Badges**: Metadata for organizing and categorizing messages

## Usage Flow

1. **User Registration**: Create User → Create Profile → Optionally create Auth record
2. **Avatar Selection**: User browses avatar library → Adds avatars to profile via ProfileAvatar
3. **Start Chat**: User selects an avatar from their collection → Creates new Chat
4. **Messaging**: Chat generates Messages → Messages can be tagged/badged for organization
5. **Multi-user Avatars**: Same avatar can simultaneously chat with multiple users

## Migration Notes

- Existing Profile.fullName/email → User.name/email
- Existing Profile.avatarID → ProfileAvatar many-to-many relationship
- New Chat and Message entities for conversation management
- Enhanced Avatar model with character attributes and sharing capabilities