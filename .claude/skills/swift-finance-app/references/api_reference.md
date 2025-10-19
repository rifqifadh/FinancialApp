# Quick Reference Guide

Quick reference for common patterns and code snippets used throughout the app.

## Common Imports

```swift
// Standard
import SwiftUI
import Foundation

// Supabase
import Supabase

// Charts
import Charts
```

## Date Formatting

```swift
extension Date {
    func formatShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    func formatMedium() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    func formatRelative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
```

## Decimal Formatting

```swift
extension Decimal {
    func formatAsCurrency(code: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
    
    func formatAsPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "0%"
    }
}
```

## Common View Modifiers

```swift
extension View {
    /// Apply card style
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Apply section header style
    func sectionHeader() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal)
    }
}
```

## Async/Await Patterns

### ViewModel Task Execution

```swift
func performAction() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        try await someAsyncOperation()
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### View Task Modifier

```swift
.task {
    await viewModel.fetchData()
}
```

### Button with Async Action

```swift
Button("Save") {
    Task {
        await viewModel.save()
    }
}
```

## Error Handling

### Custom Error Enum

```swift
enum FinanceAppError: Error, LocalizedError {
    case networkError
    case authenticationFailed
    case databaseError(String)
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .authenticationFailed:
            return "Authentication failed"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .invalidData:
            return "Invalid data received"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
```

### Try/Catch Pattern

```swift
do {
    let result = try await service.fetchData()
    // Handle success
} catch let error as FinanceAppError {
    // Handle app-specific error
    errorMessage = error.localizedDescription
} catch {
    // Handle generic error
    errorMessage = "An unexpected error occurred"
}
```

## Supabase Shortcuts

### Basic Query

```swift
let items: [Item] = try await supabase.database
    .from("table_name")
    .select()
    .execute()
    .value
```

### With Filter

```swift
let items: [Item] = try await supabase.database
    .from("table_name")
    .select()
    .eq("column", value: someValue)
    .execute()
    .value
```

### With Join

```swift
let items: [Item] = try await supabase.database
    .from("table_name")
    .select("*, related_table(*)")
    .execute()
    .value
```

### With Ordering

```swift
let items: [Item] = try await supabase.database
    .from("table_name")
    .select()
    .order("created_at", ascending: false)
    .execute()
    .value
```

## SwiftUI Previews

### Basic Preview

```swift
#Preview {
    ContentView()
}
```

### Preview with State

```swift
#Preview {
    struct PreviewWrapper: View {
        @State private var value = "Test"
        
        var body: some View {
            MyView(value: $value)
        }
    }
    
    return PreviewWrapper()
}
```

### Preview with Environment Object

```swift
#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
```

## Common SF Symbols

```swift
// Money & Finance
"dollarsign.circle"
"creditcard"
"banknote"
"chart.line.uptrend.xyaxis"
"chart.pie"

// Categories
"house"
"car"
"fork.knife"
"cart"
"tag"

// Navigation
"house.fill"
"chart.bar.fill"
"gearshape.fill"
"person.fill"

// Actions
"plus"
"minus"
"pencil"
"trash"
"arrow.up.arrow.down"
```

## Performance Tips

1. **Use `@StateObject` for ViewModels**
   ```swift
   @StateObject private var viewModel = MyViewModel()
   ```

2. **Mark ViewModels with `@MainActor`**
   ```swift
   @MainActor
   class MyViewModel: ObservableObject { }
   ```

3. **Use `id()` modifier for list updates**
   ```swift
   List(items, id: \.id) { item in
       ItemRow(item: item)
   }
   .id(UUID()) // Force refresh when needed
   ```

4. **Debounce search queries**
   ```swift
   .onChange(of: searchText) { newValue in
       searchDebouncer.debounce {
           performSearch(newValue)
       }
   }
   ```
