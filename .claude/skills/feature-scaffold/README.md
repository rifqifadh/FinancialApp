# Feature Scaffold Skill

A Claude Code skill for generating features and components in the FinancialApp codebase.

## What This Skill Does

This skill helps generate:
- Complete feature modules (Model + Service + ViewModel + View)
- Supabase services with CRUD operations
- Reusable SwiftUI components following AppTheme
- Add/Edit forms with validation

## How It Works

When you ask Claude to create a new feature or component, this skill:
1. References the established architectural patterns
2. Generates code following MVVM + Dependencies architecture
3. Uses AppTheme design system consistently
4. Implements Supabase integration properly
5. Includes proper validation, error handling, and state management

## Architecture Covered

- **MVVM**: Using @Observable ViewModels and SwiftUI Views
- **Dependencies**: Point-Free Dependencies pattern for dependency injection
- **Supabase**: Service layer for database operations
- **AppTheme**: Consistent design system for UI components
- **ViewState**: Async operation state management

## Reference Files

The skill includes comprehensive reference documentation:

- `references/architecture-patterns.md` - MVVM, ViewModels, Services, Models
- `references/ui-design-system.md` - AppTheme usage and UI patterns
- `references/project-structure.md` - File organization and naming

## Example Usage

```
"Create a Categories feature with CRUD operations"
"Generate a Budgets service for Supabase"
"Build a MonthlySpendingCard component"
"Create an AddTransaction form with validation"
```

## Skill Structure

```
feature-scaffold/
├── SKILL.md                              # Main skill instructions
├── README.md                             # This file
├── references/
│   ├── architecture-patterns.md          # MVVM, Dependencies, ViewState
│   ├── ui-design-system.md               # AppTheme, components, patterns
│   └── project-structure.md              # File organization, naming
├── scripts/                              # (empty - no scripts needed)
└── assets/                               # (empty - no assets needed)
```

## Key Patterns

### MVVM with Observable
- ViewModels use `@Observable` (not ObservableObject)
- ViewModels are `@MainActor` isolated
- Views use `@State private var viewModel`

### Point-Free Dependencies
- Services injected via `@Dependency` property wrapper
- Both `liveValue` and `testValue` implementations
- No singletons or global state

### ViewState Pattern
- Async operations use `ViewState<T>` enum
- States: idle, loading, success, error, empty
- UI uses `ViewStateView` for state handling

### AppTheme Design System
- All colors from `AppTheme.Colors`
- All typography from `AppTheme.Typography`
- All spacing from `AppTheme.Spacing`
- Consistent corner radius and shadows

## Created By

Generated from the FinancialApp codebase patterns, specifically:
- Accounts feature (AccountModel, AccountsView, AccountsViewModel, AccountService)
- AddAccount feature (AddAccountView, AddAccountViewModel, AddAccountMode)
- AppTheme design system
- ViewState pattern
- Point-Free Dependencies integration
