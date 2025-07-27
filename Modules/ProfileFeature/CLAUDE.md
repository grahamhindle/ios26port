# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS SwiftUI framework called `ProfileFeature` that provides profile management functionality. The project is structured as an Xcode framework with a demo app, using iOS 26.0 as the deployment target and Swift 5.0.

## Build and Test Commands

Since this is an Xcode project, use the following commands:

**Build the framework:**
```bash
xcodebuild -project ProfileFeature.xcodeproj -scheme ProfileFeature -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Build the demo app:**
```bash
xcodebuild -project ProfileFeature.xcodeproj -scheme Demo -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Run tests:**
```bash
xcodebuild test -project ProfileFeature.xcodeproj -scheme ProfileFeatureTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run demo app tests:**
```bash
xcodebuild test -project ProfileFeature.xcodeproj -scheme DemoTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run UI tests:**
```bash
xcodebuild test -project ProfileFeature.xcodeproj -scheme DemoUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

### Framework Structure
- **ProfileFeature.framework**: The main framework containing profile management functionality
- **Demo.app**: A demonstration app that showcases the framework's capabilities
- **SharedModels**: External dependency providing data models (Profile, User, etc.)
- **SharingGRDB**: External dependency for database functionality using GRDB

### Key Components
- **ProfileView**: Main SwiftUI view displaying a list of profiles with sections for users and tags
- **ProfileRow**: Individual row component for displaying profile information with theme colors
- **ProfileModel**: Data model managing profile operations (referenced but not directly visible in sources)

### Dependencies
- **SharedModels**: Contains Profile, User, Avatar, Tag, and other data models
- **SharingGRDB**: Database layer using GRDB with sharing capabilities
- **SwiftUI**: UI framework
- **Testing**: Uses Swift Testing framework (not XCTest)

### Database Integration
The project uses GRDB for database operations through the SharingGRDB library. Database setup is handled in `ProfileDemoApp.swift` with dependency injection pattern using `@Dependency(\.context)`.

### Testing Framework
Uses Swift Testing framework (not XCTest) for unit tests. Test files use `import Testing` and `@Test` attributes rather than XCTest patterns.

## Development Notes

- The project uses iOS 26.0 deployment target with Xcode 26.0
- Development team ID is configured as `2W35ZL7A5C`
- Uses modern Swift features including `@Bindable`, `@Dependency`, and SwiftUI previews
- Color theming is implemented with hex color support via custom Color extension
- The framework follows a modular architecture separating UI components from data models