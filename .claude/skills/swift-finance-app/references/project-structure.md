# Project Structure Guide

This document outlines the recommended folder structure and organization for your Swift 6 + SwiftUI + Supabase finance app.

## Recommended Structure

```
FinanceApp/
├── FinanceApp.swift                    # App entry point
├── Info.plist
├── Assets.xcassets/                    # Images, colors, app icons
├── Config/
│   ├── Config.xcconfig                 # Environment configuration
│   └── Secrets.swift                   # API keys (gitignored)
├── Models/
│   ├── User/
│   │   └── UserProfile.swift
│   ├── Expense/
│   │   ├── Expense.swift
│   │   ├── ExpenseCategory.swift
│   │   └── ExpenseSummary.swift
│   ├── Asset/
│   │   ├── Asset.swift
│   │   └── AssetType.swift
│   ├── Investment/
│   │   ├── Investment.swift
│   │   └── InvestmentPerformance.swift
│   └── Budget/
│       └── Budget.swift
├── ViewModels/
│   ├── Auth/
│   │   └── AuthViewModel.swift
│   ├── Expense/
│   │   ├── ExpenseListViewModel.swift
│   │   └── ExpenseFormViewModel.swift
│   ├── Asset/
│   │   ├── AssetListViewModel.swift
│   │   └── AssetDetailViewModel.swift
│   ├── Investment/
│   │   └── InvestmentPortfolioViewModel.swift
│   └── Budget/
│       └── BudgetViewModel.swift
├── Views/
│   ├── Root/
│   │   ├── ContentView.swift
│   │   └── MainTabView.swift
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   └── ForgotPasswordView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── Components/
│   │   │   ├── SummaryCard.swift
│   │   │   ├── RecentExpensesCard.swift
│   │   │   └── BudgetOverviewCard.swift
│   ├── Expense/
│   │   ├── ExpenseListView.swift
│   │   ├── ExpenseDetailView.swift
│   │   ├── ExpenseFormView.swift
│   │   └── Components/
│   │       ├── ExpenseRow.swift
│   │       └── ExpenseFilterView.swift
│   ├── Asset/
│   │   ├── AssetListView.swift
│   │   ├── AssetDetailView.swift
│   │   ├── AssetFormView.swift
│   │   └── Components/
│   │       └── AssetCard.swift
│   ├── Investment/
│   │   ├── PortfolioView.swift
│   │   ├── InvestmentDetailView.swift
│   │   └── Components/
│   │       ├── PerformanceChart.swift
│   │       └── HoldingRow.swift
│   ├── Budget/
│   │   ├── BudgetListView.swift
│   │   ├── BudgetFormView.swift
│   │   └── Components/
│   │       └── BudgetProgressCard.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ProfileView.swift
│   │   └── CategoryManagementView.swift
│   └── Shared/
│       ├── Components/
│       │   ├── CategoryPicker.swift
│       │   ├── CurrencyTextField.swift
│       │   ├── DateRangePicker.swift
│       │   └── ChartLegend.swift
│       └── Modifiers/
│           ├── CardStyle.swift
│           └── ShimmerEffect.swift
├── Services/
│   ├── Supabase/
│   │   ├── Params/
│   │   │    └── ExpensesFilterParams.swift
│   │   ├── Response/
│   │   │    ├── ExpenseCategoryResponse.swift
│   │   │    ├── ExpenseResponse.swift
│   │   │    └── ExpensesSummaryResponse.swift
│   │   ├── SupabaseManager.swift       # Singleton client
│   │   ├── AuthService.swift           # Authentication operations
│   │   ├── ExpenseService.swift        # Expense CRUD
│   │   ├── AssetService.swift          # Asset CRUD
│   │   ├── InvestmentService.swift     # Investment CRUD
│   │   └── CategoryService.swift       # Category operations
│   ├── Networking/
│   │   └── APIClient.swift             # External API calls (e.g., stock prices)
│   └── Storage/
│       └── LocalStorageService.swift   # UserDefaults, CoreData
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Decimal+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   ├── Helpers/
│   │   ├── CurrencyFormatter.swift
│   │   ├── DateFormatter.swift
│   │   └── ErrorHandler.swift
│   └── Constants/
│       ├── AppConstants.swift
│       └── Colors.swift
└── Tests/
    ├── UnitTests/
    │   ├── ViewModelTests/
    │   └── ServiceTests/
    └── UITests/
        └── SnapshotTests/
```

## Detailed Explanations

### Models/
Contains all data models that match your Supabase database schema. Each model should:
- Conform to `Codable` and `Identifiable`
- Use snake_case for CodingKeys to match database columns
- Include computed properties for derived values

**Example:**
```swift
// Models/Expense/Expense.swift
struct Expense: Identifiable {
    let id: UUID
    let userId: UUID
    let amount: Decimal
    // ... other properties
}
```

### Response/
Contains all data models that match your Supabase database schema. Each model should:
- Conform to `Codable` and `Identifiable`
- Use snake_case for CodingKeys to match database columns
- Include computed properties for derived values

**Example:**
```swift
// Models/Expense/Expense.swift
nonisolated struct ExpenseResponse: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let amount: Decimal
    // ... other properties
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amount
    }
}
```

### ViewModels/
Implements MVVM pattern. Each ViewModel should:
- Be an `@Observable` macro
- Handle business logic and state management
- Communicate with Services
- Never directly access Views

**Example:**
```swift
// ViewModels/Expense/ExpenseListViewModel.swift
@MainActor
@Observable
class ExpenseListViewModel {
    var expenses: [Expense] = []
    var isLoading = false
    var errorMessage: String?
    
    private let expenseService: ExpenseService
    
    init(expenseService: ExpenseService = ExpenseService()) {
        self.expenseService = expenseService
    }
    
    func fetchExpenses() async {
        // Implementation
    }
}
```

### Views/
SwiftUI views organized by feature. Follow these guidelines:
- Keep views small and focused
- Extract reusable components into `Shared/Components/`
- Use view modifiers from `Shared/Modifiers/`
- Inject ViewModels via `@StateObject` or `@ObservedObject`

**Example:**
```swift
// Views/Expense/ExpenseListView.swift
struct ExpenseListView: View {
    @Binding private var viewModel = ExpenseListViewModel()
    
    var body: some View {
        // Implementation
    }
}
```

### Services/
Handle all data operations. Each service should:
- Be independent and testable
- Use async/await for asynchronous operations
- Throw typed errors
- Be injectable for testing

**Example:**
```swift
// Services/Supabase/ExpenseService.swift
class ExpenseService {
    private let supabase = SupabaseManager.shared.client
    
    func fetchExpenses() async throws -> [Expense] {
        // Implementation
    }
}
```

### Utilities/
Shared utilities, extensions, and constants:
- **Extensions**: Extend existing types with helpful methods
- **Helpers**: Utility classes for formatting, validation, etc.
- **Constants**: App-wide constants (colors, strings, URLs)

## File Naming Conventions

- **Swift files**: PascalCase (e.g., `ExpenseListView.swift`)
- **Model files**: Match type name (e.g., `Expense.swift`)
- **ViewModel files**: Feature + ViewModel (e.g., `ExpenseListViewModel.swift`)
- **Service files**: Feature + Service (e.g., `ExpenseService.swift`)
- **Component files**: Descriptive name (e.g., `CategoryPicker.swift`)

## Code Organization Best Practices

### 1. Single Responsibility
Each file should have one clear purpose. Don't mix concerns.

### 2. Dependency Injection
Inject dependencies (services, managers) rather than creating them internally.

```swift
// Good
class ExpenseListViewModel: ObservableObject {
    private let expenseService: ExpenseService
    
    init(expenseService: ExpenseService) {
        self.expenseService = expenseService
    }
}

// Avoid
class ExpenseListViewModel: ObservableObject {
    private let expenseService = ExpenseService()
}
```

### 3. Protocol-Oriented Programming
Define protocols for services to enable testing.

```swift
protocol ExpenseServiceProtocol {
    func fetchExpenses() async throws -> [Expense]
}

class ExpenseService: ExpenseServiceProtocol {
    // Implementation
}
```

### 4. Environment Objects
Use `@EnvironmentObject` for app-wide state:
- User session
- App settings
- Theme preferences

```swift
@main
struct FinanceApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
```

### 5. Group Related Files
Keep related files together in subfolders:
- Group by feature (Expense, Asset, Investment)
- Keep components near their parent views
- Organize tests to mirror app structure

## Feature Module Pattern

For larger features, consider this self-contained structure:

```
Expense/
├── Models/
│   └── Expense.swift
├── ViewModels/
│   └── ExpenseListViewModel.swift
├── Views/
│   ├── ExpenseListView.swift
│   └── Components/
│       └── ExpenseRow.swift
└── Services/
    └── ExpenseService.swift
```

## Testing Organization

Match your test structure to your app structure:

```
Tests/
├── UnitTests/
│   ├── Models/
│   ├── ViewModels/
│   │   └── ExpenseListViewModelTests.swift
│   └── Services/
│       └── ExpenseServiceTests.swift
└── UITests/
    └── ExpenseFlowTests.swift
```

## Navigation Patterns

### Tab-Based Navigation
```swift
TabView {
    DashboardView()
        .tabItem { Label("Dashboard", systemImage: "house") }
    
    ExpenseListView()
        .tabItem { Label("Expenses", systemImage: "dollarsign.circle") }
    
    // ... other tabs
}
```

### Navigation Stack (iOS 16+)
```swift
NavigationStack {
    ExpenseListView()
        .navigationDestination(for: Expense.self) { expense in
            ExpenseDetailView(expense: expense)
        }
}
```

## Asset Organization

```
Assets.xcassets/
├── AppIcon.appiconset/
├── Colors/
│   ├── Primary.colorset/
│   ├── Success.colorset/
│   ├── Warning.colorset/
│   └── Error.colorset/
├── Icons/
│   ├── TabBar/
│   └── Categories/
└── Images/
    ├── Onboarding/
    └── EmptyStates/
```

## Configuration Files

### Config.xcconfig
```
SUPABASE_URL = https://your-project.supabase.co
// Don't commit keys! Use environment variables
```

### .gitignore
```
# Secrets
Secrets.swift
*.xcconfig

# Build
build/
*.pbxuser

# User-specific
*.xcuserstate
```

## TODO: Customization Checklist

- [ ] Set up your project with this structure
- [ ] Create base ViewModels and Services
- [ ] Configure environment variables
- [ ] Set up dependency injection
- [ ] Create reusable components
- [ ] Establish naming conventions with your team
- [ ] Set up CI/CD pipelines
- [ ] Configure code formatters (SwiftLint)
