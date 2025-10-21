# Project Structure - FinancialApp

## Directory Organization

```
FinancialApp/
├── Model/
│   └── {Feature}/
│       ├── {Feature}Model.swift
│       └── {Feature}Category.swift (if needed)
│
├── Presentation/
│   ├── {Feature}/
│   │   ├── {Feature}View.swift
│   │   ├── {Feature}ViewModel.swift
│   │   ├── {Feature}Card.swift (reusable components)
│   │   └── {Feature}.swift (if needed)
│   │
│   ├── Add{Feature}/
│   │   ├── Add{Feature}View.swift
│   │   └── Add{Feature}ViewModel.swift
│   │
│   └── Shared/ (or SharedUI/)
│       ├── ViewState.swift
│       ├── LoadingView.swift
│       └── (other shared components)
│
├── Services/
│   └── Supabase/
│       ├── {Feature}Service.swift
│       ├── SupabaseManager.swift
│       └── Response/
│           └── {Feature}/
│               └── {Feature}Response.swift (if needed)
│
├── Utilities/
│   ├── Extensions/
│   │   ├── Int+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── View+Extension.swift
│   │
│   ├── ErrorHandling/
│   │   ├── AppError.swift
│   │   └── ErrorHandler.swift
│   │
│   └── ViewModifier/
│       ├── CustomFocus.swift
│       └── FrameGetter.swift
│
├── Theme/
│   └── Theme.swift (AppTheme)
│
└── RootView.swift
```

## File Naming Conventions

### Models
- `{Feature}Model.swift` - Main model file
- `{Feature}Category.swift` - If feature has category enum
- Example: `AccountModel.swift`, `TransactionModel.swift`

### Views
- `{Feature}View.swift` - Main list/overview view
- `{Feature}Card.swift` - Reusable card components
- `Add{Feature}View.swift` - Form for adding/editing
- Example: `AccountsView.swift`, `AccountCard.swift`, `AddAccountView.swift`

### ViewModels
- `{Feature}ViewModel.swift` - For list/overview
- `Add{Feature}ViewModel.swift` - For add/edit forms
- Example: `AccountsViewModel.swift`, `AddAccountViewModel.swift`

### Services
- `{Feature}Service.swift` - Service layer
- Example: `AccountService.swift`, `TransactionService.swift`

## Feature Creation Checklist

When creating a new feature, create files in this order:

1. **Model Layer** (`Model/{Feature}/`)
   - [ ] `{Feature}Model.swift` - Define the data model
   - [ ] Add mock data for previews
   - [ ] Ensure Identifiable, Codable, Sendable conformance
   - [ ] Add CodingKeys for snake_case mapping

2. **Service Layer** (`Services/Supabase/`)
   - [ ] `{Feature}Service.swift` - Define service protocol and implementation
   - [ ] Create Create{Feature}Params struct
   - [ ] Create Update{Feature}Params struct
   - [ ] Implement DependencyKey with liveValue and testValue
   - [ ] Add extension to DependencyValues

3. **ViewModel Layer** (`Presentation/{Feature}/`)
   - [ ] `{Feature}ViewModel.swift` - Business logic and state
   - [ ] Inject {Feature}Service dependency
   - [ ] Add ViewState for async operations
   - [ ] Implement load/refresh/delete actions

4. **View Layer** (`Presentation/{Feature}/`)
   - [ ] `{Feature}View.swift` - Main UI
   - [ ] Use ViewStateView for state handling
   - [ ] Add .task for initial load
   - [ ] Include #Preview

5. **Reusable Components** (if needed)
   - [ ] `{Feature}Card.swift` - Card components
   - [ ] Follow AppTheme patterns
   - [ ] Include #Preview variants

6. **Add/Edit Forms** (if needed) (`Presentation/Add{Feature}/`)
   - [ ] `Add{Feature}View.swift` - Form UI
   - [ ] `Add{Feature}ViewModel.swift` - Form logic
   - [ ] Create mode enum (add/edit)
   - [ ] Add validation logic
   - [ ] Include save/update actions

## Import Guidelines

Standard imports for each file type:

### Model
```swift
import Foundation
```

### ViewModel
```swift
import Dependencies
import Foundation
import Observation
```

### View
```swift
import SwiftUI
```

### Service
```swift
import Dependencies
import Foundation
import Supabase
```

## Code Organization with MARK

Use MARK comments consistently:

### In ViewModels
```swift
// MARK: - State
// MARK: - Computed Properties
// MARK: - Actions
```

### In Views
```swift
// MARK: - Properties
// MARK: - Body
// MARK: - Actions
// MARK: - Helper Methods
```

### In Services
```swift
// MARK: - Request Parameters
// MARK: - Dependency Key
// MARK: - Dependency Values
```

### In Models
```swift
// MARK: - Computed Properties
// MARK: - Mock Data
```

## Supabase Table Naming

- Tables use snake_case: `accounts`, `transactions`, `categories`
- Foreign keys: `user_id`, `account_id`, `category_id`
- Timestamps: `created_at`, `updated_at`
- Always use CodingKeys for proper mapping in Swift models
