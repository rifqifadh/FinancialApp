# Architecture Patterns - FinancialApp

This document outlines the architectural patterns used in the FinancialApp codebase.

## MVVM Architecture

### ViewModel Structure

ViewModels follow these patterns:

```swift
import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class {Feature}ViewModel {
  @ObservationIgnored
  @Dependency(\.{feature}Service) var {feature}Service

  // MARK: - State
  var items: [{Feature}Model] = []
  var isLoading = false
  var errorMessage: String?
  var {feature}StateView: ViewState<[{Feature}Model]> = .idle

  // MARK: - Computed Properties
  // Add computed properties for derived state

  // MARK: - Actions
  func load{Feature}s() async {
    {feature}StateView = .loading
    do {
      let items = try await {feature}Service.fetchAll()
      self.items = items
      {feature}StateView = items.isEmpty ? .empty : .success(items)
    } catch {
      let errorMessage = "Failed to load: \(error.localizedDescription)"
      self.errorMessage = errorMessage
      {feature}StateView = .error(error)
    }
  }

  func refresh() async {
    await load{Feature}s()
  }
}
```

**Key Points:**
- Use `@MainActor` for all ViewModels
- Use `@Observable` for state management
- Inject dependencies using `@Dependency` with `@ObservationIgnored`
- Use `ViewState<T>` enum for async operations (idle, loading, success, error, empty)
- Organize code with MARK comments: State, Computed Properties, Actions

### View Structure

Views follow these patterns:

```swift
import SwiftUI

struct {Feature}View: View {
  @State private var viewModel = {Feature}ViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      // Use ViewStateView for handling async states
      ViewStateView(
        state: viewModel.{feature}StateView,
        content: { items in
          List(items) { item in
            // Item view
          }
        },
        emptyView: {
          ContentUnavailableView(
            "No {Feature}s",
            systemImage: "tray",
            description: Text("Add your first {feature}")
          )
        },
        errorView: { error in
          DefaultErrorView(error: error)
        },
        retry: {
          Task { await viewModel.load{Feature}s() }
        }
      )
      .navigationTitle("{Feature}s")
      .task {
        await viewModel.load{Feature}s()
      }
    }
  }
}

#Preview {
  {Feature}View()
}
```

**Key Points:**
- Use `@State private var viewModel` for ViewModel instances
- Use `NavigationStack` for navigation
- Use `ViewStateView` for handling loading/error/empty states
- Use `.task {}` for initial data loading
- Always include #Preview for UI components

## Point-Free Dependencies Pattern

### Service Definition

```swift
import Dependencies
import Foundation
import Supabase

struct {Feature}Service: Sendable {
  var fetchAll: @Sendable () async throws -> [{Feature}Model]
  var fetchById: @Sendable (_ id: String) async throws -> {Feature}Model?
  var create: @Sendable (_ params: Create{Feature}Params) async throws -> {Feature}Model
  var update: @Sendable (_ id: String, _ params: Update{Feature}Params) async throws -> {Feature}Model
  var delete: @Sendable (_ id: String) async throws -> Void
}

// MARK: - Request Parameters
struct Create{Feature}Params: Codable, Sendable {
  let field1: String
  let field2: String
  // Use snake_case in CodingKeys for Supabase

  enum CodingKeys: String, CodingKey {
    case field1 = "field_1"
    case field2 = "field_2"
  }
}

struct Update{Feature}Params: Codable, Sendable {
  let field1: String?
  let field2: String?

  enum CodingKeys: String, CodingKey {
    case field1 = "field_1"
    case field2 = "field_2"
  }
}

// MARK: - Dependency Key
extension {Feature}Service: DependencyKey {
  static let liveValue = {Feature}Service(
    fetchAll: {
      let items: [{Feature}Model] = try await SupabaseManager.shared.client
        .from("{table_name}")
        .select()
        .order("created_at", ascending: false)
        .execute()
        .value
      return items
    },
    fetchById: { id in
      let items: [{Feature}Model] = try await SupabaseManager.shared.client
        .from("{table_name}")
        .select()
        .eq("id", value: id)
        .execute()
        .value
      return items.first
    },
    create: { params in
      let item: {Feature}Model = try await SupabaseManager.shared.client
        .from("{table_name}")
        .insert(params)
        .select()
        .single()
        .execute()
        .value
      return item
    },
    update: { id, params in
      let item: {Feature}Model = try await SupabaseManager.shared.client
        .from("{table_name}")
        .update(params)
        .eq("id", value: id)
        .select()
        .single()
        .execute()
        .value
      return item
    },
    delete: { id in
      try await SupabaseManager.shared.client
        .from("{table_name}")
        .delete()
        .eq("id", value: id)
        .execute()
    }
  )

  static let testValue = {Feature}Service(
    fetchAll: { [] },
    fetchById: { _ in nil },
    create: { _ in .mock },
    update: { _, _ in .mock },
    delete: { _ in }
  )
}

// MARK: - Dependency Values
extension DependencyValues {
  var {feature}Service: {Feature}Service {
    get { self[{Feature}Service.self] }
    set { self[{Feature}Service.self] = newValue }
  }
}
```

**Key Points:**
- All services must conform to `Sendable`
- All service methods must be `@Sendable`
- Define separate Params types for create/update operations
- Use snake_case in CodingKeys for Supabase field mapping
- Provide both `liveValue` and `testValue` implementations
- Access Supabase via `SupabaseManager.shared.client`

## Model Structure

```swift
import Foundation

struct {Feature}Model: Identifiable, Codable, Sendable {
  let id: String
  let userId: String
  let field1: String
  let field2: Int
  let createdAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case field1 = "field_1"
    case field2 = "field_2"
    case createdAt = "created_at"
  }

  // Computed properties
  var displayName: String {
    field1
  }
}

// MARK: - Mock Data
extension {Feature}Model {
  static let mock = {Feature}Model(
    id: "1",
    userId: "user1",
    field1: "Sample",
    field2: 100,
    createdAt: Date()
  )

  static let mockList = [mock]
}
```

**Key Points:**
- All models must conform to `Identifiable, Codable, Sendable`
- Use snake_case in CodingKeys for Supabase field mapping
- Include mock data for previews and testing
- Add computed properties for derived values

## ViewState Pattern

Use the `ViewState<T>` enum for managing async operation states:

```swift
enum ViewState<T> {
  case idle
  case loading
  case success(T)
  case error(Error)
  case empty
}
```

**Usage in ViewModel:**
```swift
var itemsState: ViewState<[ItemModel]> = .idle

func loadItems() async {
  itemsState = .loading
  do {
    let items = try await service.fetchAll()
    itemsState = items.isEmpty ? .empty : .success(items)
  } catch {
    itemsState = .error(error)
  }
}
```

**Usage in View:**
```swift
ViewStateView(
  state: viewModel.itemsState,
  content: { items in
    List(items) { item in
      Text(item.name)
    }
  },
  emptyView: {
    ContentUnavailableView("No Items", systemImage: "tray")
  },
  errorView: { error in
    DefaultErrorView(error: error)
  },
  retry: {
    Task { await viewModel.loadItems() }
  }
)
```
