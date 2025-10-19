---
name: swift-finance-app
description: Development guide for Swift 6 + SwiftUI financial management application with Supabase backend. Use when working on asset tracking, expense management, investment portfolio, or spending analysis features. Includes project architecture, database schemas, API integration patterns, and SwiftUI components for financial data visualization.
---

# Swift Finance App Development Guide

This skill provides comprehensive guidance for developing your Swift 6 + SwiftUI financial management application with Supabase backend.

## Project Overview

**Tech Stack:**
- Frontend: Swift 6, SwiftUI
- Backend: Supabase (PostgreSQL, Auth, Storage, Realtime)
- Architecture: MVVM pattern with async/await
- Key Features: Asset management, expense tracking, investment portfolio, spending analysis

## Quick Start Workflow

1. **Review project structure** - See `references/project-structure.md` for folder organization
2. **Understand database schema** - See `references/database-schema.md` for table definitions
3. **Check API patterns** - See `references/supabase-integration.md` for client setup and queries
4. **Use UI components** - See `references/swiftui-components.md` for reusable views
5. **Review code templates** - See `assets/templates/` for boilerplate code

## Core Development Patterns

### Database Operations
- Always use type-safe queries with Codable models
- Implement proper error handling with custom error types
- Use async/await for all database operations
- Follow RLS (Row Level Security) policies defined in schema

### SwiftUI Best Practices
- Use `@@Observable` macro for view models
- Implement `@EnvironmentObject` for shared state (user session, settings)
- Create reusable view components for financial data display
- Use `Task` for async operations in views

### Supabase Integration
- Initialize client once in App delegate
- Use environment variables for API keys
- Implement proper authentication flow
- Subscribe to realtime updates for collaborative features

## File Organization

```
YourApp/
├── Models/          # Data models matching DB schema
├── ViewModels/      # Business logic and state management  
├── Views/           # SwiftUI views
├── Services/        # API and database services
├── Utilities/       # Helpers and extensions
└── Resources/       # Assets and configuration
```

## When to Use References

- **Database Schema** (`references/database-schema.md`) - When creating models or writing queries
- **SwiftUI Components** (`references/swiftui-components.md`) - When building financial UI elements
- **Project Structure** (`references/project-structure.md`) - When organizing new features

## When to Use Assets

- **Boilerplate Templates** (`assets/templates/`) - When creating new features from scratch
- Copy templates and customize for your specific use case

## Common Tasks

**Adding a new expense:**
1. Create model matching `expenses` table schema
2. Implement ViewModel with insert method
3. Build SwiftUI form view
4. Connect to Supabase client

**Building a chart:**
1. Use Chart framework with SwiftUI
2. Fetch aggregated data from database
3. Transform data for visualization
4. Implement reusable chart component

**Implementing categories:**
1. Reference `categories` table schema
2. Create picker view component
3. Link to expense/asset records via foreign keys
