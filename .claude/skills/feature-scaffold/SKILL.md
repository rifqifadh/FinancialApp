---
name: feature-scaffold
description: Generate complete features and reusable UI components for FinancialApp following MVVM architecture, Point-Free Dependencies pattern, Supabase integration, and AppTheme design system. Use this skill when creating new features (Model + View + ViewModel + Service), adding Supabase services, or building reusable SwiftUI components.
---

# Feature Scaffold

Generate code for FinancialApp following established architectural patterns, dependency injection, and design system guidelines.

## When to Use This Skill

Use this skill when:
- Creating a new feature module (e.g., Budgets, Categories, Statistics)
- Adding a Supabase service for CRUD operations
- Building reusable UI components (Cards, Forms, Lists)
- Scaffolding add/edit forms with validation
- Need to follow the existing MVVM + Dependencies architecture

## How to Use This Skill

### Step 1: Understand the Request

Clarify what needs to be generated:
- **Full Feature**: Model + Service + ViewModel + View + Components
- **Service Only**: Just the Supabase service layer
- **UI Component**: Reusable SwiftUI component following AppTheme
- **Form**: Add/Edit view with ViewModel and validation

### Step 2: Reference Architecture Patterns

Load and reference the architecture documentation:
- `references/architecture-patterns.md` - MVVM, Dependencies, ViewState patterns
- `references/ui-design-system.md` - AppTheme usage, component patterns
- `references/project-structure.md` - File organization, naming conventions

Use grep to quickly find relevant patterns:
```bash
# Find ViewModel patterns
grep -n "ViewModel Structure" references/architecture-patterns.md

# Find UI component patterns
grep -n "Card Component Pattern" references/ui-design-system.md

# Find file organization
grep -n "Feature Creation Checklist" references/project-structure.md
```

### Step 3: Generate Code Following Patterns

When generating code:

1. **Follow the established patterns exactly** as shown in references
2. **Use proper file organization** from `project-structure.md`
3. **Apply AppTheme consistently** using patterns from `ui-design-system.md`
4. **Implement Dependencies properly** following `architecture-patterns.md`

### Step 4: Feature Generation Workflow

For a complete feature, generate files in this order:

#### 1. Model (`Model/{Feature}/{Feature}Model.swift`)
- Conform to `Identifiable, Codable, Sendable`
- Add CodingKeys for snake_case mapping to Supabase
- Include computed properties for derived values
- Add mock data for previews

#### 2. Service (`Services/Supabase/{Feature}Service.swift`)
- Define service protocol with `@Sendable` closures
- Create `Create{Feature}Params` and `Update{Feature}Params` structs
- Implement `DependencyKey` with `liveValue` using SupabaseManager
- Provide `testValue` for testing
- Add extension to `DependencyValues`

#### 3. ViewModel (`Presentation/{Feature}/{Feature}ViewModel.swift`)
- Mark with `@MainActor` and `@Observable`
- Inject service using `@Dependency(\.{feature}Service)`
- Add `ViewState<[{Feature}Model]>` for async operations
- Implement load/refresh/delete actions
- Include computed properties for filtering/grouping

#### 4. View (`Presentation/{Feature}/{Feature}View.swift`)
- Use `@State private var viewModel` for ViewModel
- Use `ViewStateView` for handling loading/error/empty states
- Add `.task {}` for initial data loading
- Include navigation, toolbars, and actions
- Add `#Preview` with sample data

#### 5. Components (if needed) (`Presentation/{Feature}/{Feature}Card.swift`)
- Create reusable card components
- Follow AppTheme patterns for colors, typography, spacing
- Make components configurable with parameters
- Include multiple `#Preview` variants

#### 6. Add/Edit Forms (if needed) (`Presentation/Add{Feature}/`)
- Create mode enum (`.add`, `.edit({Feature}Model)`)
- Build form ViewModel with validation
- Use SwiftUI `Form` with sections
- Add loading overlay and error alerts
- Support both create and update operations

### Step 5: Ensure Code Quality

Before delivering generated code, verify:

- [ ] All files follow naming conventions
- [ ] Proper MARK comments organize code sections
- [ ] AppTheme is used for all colors, typography, spacing
- [ ] ViewState pattern used for async operations
- [ ] Dependencies properly injected
- [ ] Mock data provided for previews
- [ ] CodingKeys match Supabase snake_case fields
- [ ] All structs/classes marked `Sendable` where appropriate
- [ ] `#Preview` included for UI components

## Key Architectural Principles

### MVVM with Observable Pattern
- ViewModels are `@Observable` (not ObservableObject)
- Use `@State private var viewModel` in Views
- ViewModels are `@MainActor` isolated

### Point-Free Dependencies
- Never use singletons or global state
- Inject dependencies via `@Dependency` property wrapper
- Define both `liveValue` and `testValue` for services
- All service closures must be `@Sendable`

### ViewState for Async Operations
- Use `ViewState<T>` enum for loading states
- Leverage `ViewStateView` in UI for state handling
- Transition: idle → loading → success/error/empty

### AppTheme Design System
- Always use `AppTheme.Colors.*` for colors
- Always use `AppTheme.Typography.*` for fonts
- Always use `AppTheme.Spacing.*` for spacing
- Always use `AppTheme.CornerRadius.*` for corner radius

### Supabase Integration
- Access via `SupabaseManager.shared.client`
- Use snake_case for table/column names
- Map to Swift camelCase via CodingKeys
- All params structs must be `Codable, Sendable`

## Examples

### Example Request: "Create a Categories feature"

Generate these files:
1. `Model/Categories/CategoryModel.swift`
2. `Services/Supabase/CategoryService.swift`
3. `Presentation/Categories/CategoriesViewModel.swift`
4. `Presentation/Categories/CategoriesView.swift`
5. `Presentation/Categories/CategoryCard.swift`
6. `Presentation/AddCategory/AddCategoryView.swift`
7. `Presentation/AddCategory/AddCategoryViewModel.swift`

### Example Request: "Create a StatisticsCard component"

Generate:
1. `Presentation/Shared/StatisticsCard.swift` (or appropriate location)
2. Follow AppTheme patterns
3. Include multiple #Preview variants
4. Make it reusable and configurable

### Example Request: "Add a TransactionService for Supabase"

Generate:
1. `Services/Supabase/TransactionService.swift`
2. Include full CRUD operations
3. Define CreateTransactionParams and UpdateTransactionParams
4. Implement DependencyKey pattern
5. Add to DependencyValues

## Common Patterns Reference

For detailed patterns, always consult the reference files:

- **ViewModels**: See "ViewModel Structure" in `architecture-patterns.md`
- **Views**: See "View Structure" in `architecture-patterns.md`
- **Services**: See "Service Definition" in `architecture-patterns.md`
- **Models**: See "Model Structure" in `architecture-patterns.md`
- **UI Components**: See component patterns in `ui-design-system.md`
- **File Organization**: See "Feature Creation Checklist" in `project-structure.md`

## Anti-Patterns to Avoid

❌ Don't use `ObservableObject` - use `@Observable`
❌ Don't use `@Published` - properties are automatically observable
❌ Don't use singletons - use Dependencies
❌ Don't hardcode colors - use AppTheme.Colors
❌ Don't hardcode fonts - use AppTheme.Typography
❌ Don't forget `Sendable` conformance
❌ Don't forget CodingKeys for Supabase mapping
❌ Don't forget mock data for models
❌ Don't forget `#Preview` for UI components
❌ Don't use camelCase for Supabase table/column names

## Additional Notes

- The app targets iOS 26.0+ and macOS 26.0+
- Swift concurrency is used throughout (`async/await`)
- Supabase credentials are in Info.plist (SUPABASE_URL, SUPABASE_API_KEY)
- Currency amounts are stored as `Int` (smallest unit, e.g., cents/rupiah)
- Use `.toCurrency()` extension for formatting currency
- All timestamps from Supabase should be `Date?` type
