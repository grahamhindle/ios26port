# Refactoring Notes

## UserFeature - SharingGRDB Simplification

**Date:** July 26, 2025
**Priority:** Medium

### Current Issue
The User/AuthenticationRecord CRUD implementation is overcomplicated. We built a complex `SelectedUsersDraft` wrapper system when SharingGRDB has simpler built-in patterns.

### Proposed Refactor
1. Use direct `User.Draft` binding instead of custom wrapper
2. Let SharingGRDB handle foreign key relationships automatically  
3. Simplify form pattern with direct `@Bindable` model usage
4. Remove `UserFormSheet` wrapper and binding complexity

### Files to Review
- `Modules/UserFeature/UserFeature/Sources/UserForm.swift`
- `Modules/UserFeature/UserFeature/Sources/UserView.swift` 
- `Modules/SharedModels/SharedModels/User/UserModel.swift`

### References
- SharingGRDB documentation on Draft patterns
- Point-Free episodes on SharingGRDB best practices

**Current status:** Working but overly complex. Refactor when time permits.