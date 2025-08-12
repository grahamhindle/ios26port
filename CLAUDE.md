# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Build Commands
- **Setup project**: `make setup` - Initial project setup, installs dependencies and generates Xcode project
- **Build**: `make build` or `tuist build`
- **Test**: `make test` or `tuist test`
- **Test specific module**: `tuist test FeatureNameTests` - Run tests for a specific module
- **Test with plan**: `xcodebuild test -project FeatureName.xcodeproj -scheme FeatureName -testPlan FeatureNameTests` - Run specific test plan
- **Generate Xcode project**: `make generate` or `tuist generate`
- **Clean**: `make clean` or `tuist clean`

### Module Development
- **Focus on specific module**: `make focus module=FeatureName`
- **Run module demo**: `make run module=FeatureName`
- **Create new module**: `make new-module name=FeatureName`
- **Show module info**: `make tuist-info module=FeatureName`

### Code Quality
- **Lint Swift code**: `make lint` (SwiftLint)
- **Format Swift code**: `make format` (SwiftFormat)
- **Check formatting**: `make format-check`
- **Auto-fix lint violations**: `make lint-fix`

### Tuist Helpers
- **Project status**: `make tuist-status`
- **Clean all artifacts**: `make tuist-clean`
- **Fresh regenerate**: `make tuist-fresh`
- **Dependency graph**: `make tuist-graph`
- **Lint project config**: `make tuist-lint`
- **Cache dependencies**: `make tuist-cache`

## Project Architecture

This is a modular iOS application built with **Tuist** for project generation and **The Composable Architecture (TCA)** for state management. The project follows a feature-based modular architecture where each feature is a separate framework.

### Core Technologies
- **Tuist 4.55.6**: Project generation and dependency management
- **Swift 6.2**: Programming language with strict concurrency enabled
- **iOS 26.0**: Deployment target
- **The Composable Architecture**: State management and architecture
- **SharingGRDB**: Database persistence and sharing
- **Auth0**: Authentication provider
- **SwiftUI**: UI framework

### Module Structure

Each module follows a consistent pattern:
```
Modules/FeatureName/
├── Project.swift              # Tuist project configuration
├── Sources/                   # Feature implementation
│   ├── FeatureName.swift     # TCA reducer
│   ├── FeatureNameView.swift # SwiftUI views
│   └── Resources.swift       # Resource access
├── Demo/                      # Standalone demo app
├── Tests/                     # Unit tests
└── README.md                 # Feature documentation
```

### Key Modules
- **AppFeature**: Main app coordinator and navigation
- **AuthFeature**: Authentication with Auth0 and Apple Sign In
- **SharedModels**: Core data models and database coordination
- **SharedResources**: Shared assets, colors, fonts, and localizations
- **UIComponents**: Reusable UI components and TCA patterns
- **UserFeature**: User management and profiles
- **AvatarFeature**: Avatar creation and management
- **Chat/Explore/Profile/TabBarFeature**: Main app features

### Configuration Files
- **Tuist.swift**: Root Tuist configuration with project handle
- **Workspace.swift**: Defines which modules are included in the workspace
- **ModuleConstants.swift**: Centralized configuration for module settings, dependencies, and Auth0 setup
- **mise.toml**: Tool version management (Tuist 4.55.6)

### Development Patterns

#### Module Creation
Use the template system for consistent module structure:
```bash
make new-module name=NewFeature
```

This creates a complete TCA feature module with:
- Project configuration with proper dependencies
- TCA reducer pattern
- SwiftUI view structure
- Demo app for isolated development
- Test scaffolding

#### Auth0 Integration
Modules requiring Auth0 are automatically configured through `ModuleConstants.swift`. The system detects Auth0 dependencies and sets up:
- Auth0.plist configuration
- Demo entitlements for Apple Sign In
- Associated domains for webcredentials

#### Database Patterns
Uses SharingGRDB for persistence with TCA integration:
- Models conform to database protocols in SharedModels
- Features use Draft patterns for forms
- Database coordination through DatabaseCoordinator

#### Testing Strategy
- **Swift Testing Framework**: Uses modern `@Test` annotations with `@Suite` organization
- **TCA Testing**: Unit tests for TCA reducers using `TestStore` with dependency injection
- **Database Testing**: Integration tests for GRDB operations and database coordination
- **Demo Apps**: Each module has runnable demo apps for isolated feature testing
- **Test Plans**: Module-specific `.xctestplan` files for organized test execution
- **Mock Objects**: Comprehensive mocking system for AuthClient and other dependencies

### Build System Details

The project uses Tuist for sophisticated dependency management:
- **External dependencies**: ComposableArchitecture, SharingGRDB, Auth0
- **Internal dependencies**: Modules depend on SharedModels and SharedResources
- **Demo dependencies**: Each module has a runnable demo app
- **Caching**: Tuist caches external dependencies for faster builds

### Development Workflow

1. **Focus development**: Use `make focus module=FeatureName` to generate only specific modules
2. **Isolated testing**: Run demo apps with `make run module=FeatureName`
3. **Clean rebuilds**: Use `make tuist-fresh` for complete regeneration
4. **Dependency visualization**: Use `make tuist-graph` to understand module relationships

### Code Style Requirements
- Swift 6.2 with strict concurrency
- SwiftLint for code quality enforcement
- SwiftFormat for consistent formatting
- TCA patterns for state management
- GRDB/SharingGRDB for persistence