# CharacterActionFeature

A feature for creating and managing character actions that generate structured Claude prompts for different development tasks.

## Overview

The CharacterActionFeature allows users to:
- Create character actions with different personalities and expertise
- Generate structured prompts for Claude based on categories (code review, debugging, etc.)
- Organize and filter character actions by type, mood, and location
- Track usage statistics and favorites

## Key Components

### CharacterAction Model
- **Prompt Categories**: Code Review, Debugging, Refactoring, Learning, Problem Solving, Architecture, Testing, Optimization, Custom
- **Character Types**: Developer, Mentor, Architect, Tester, Designer, AI, Custom
- **Character Moods**: Helpful, Enthusiastic, Patient, Analytical, Creative, Professional, Friendly, Expert
- **Character Locations**: Office, Coffee Shop, Home, Library, Workshop, Virtual, Custom

### Features
- **CharacterActionFeature**: Main feature for managing character actions
- **CharacterActionFormFeature**: Form for creating and editing character actions
- **PromptBuilderFeature**: Interactive prompt builder with real-time preview

### Views
- **CharacterActionView**: Main view displaying character actions with filtering
- **CharacterActionFormView**: Form for creating/editing character actions
- **PromptBuilderView**: Interactive prompt builder

## Usage

1. **Create Character Actions**: Define characters with specific expertise and personality
2. **Generate Prompts**: Use the prompt builder to create structured Claude prompts
3. **Organize**: Filter by category, type, and visibility
4. **Track**: Monitor usage statistics and mark favorites

## Example Prompt Generation

```
You are an expert iOS developer with a helpful personality, working from an office.

Please review this code for:
- Performance issues
- Security concerns
- Best practices
- Potential bugs
- Architecture improvements

**User Request**: Help me optimize this SwiftUI view
**Context**: iOS development with Swift, SwiftUI, and TCA
**Code**: [User's code here]
**Specific Requirements**: Performance, accessibility

Please provide a comprehensive response with:
1. Clear explanations
2. Code examples where applicable
3. Best practices
4. Step-by-step guidance if needed
```

## Dependencies

- ComposableArchitecture
- SharingGRDB
- StructuredQueriesGRDB
- SharedModels
- UIComponents 