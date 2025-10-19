# Boilerplate Templates

This directory contains boilerplate code templates to help you quickly scaffold new features.

## Available Templates

### 1. ModelTemplate.swift
Template for creating Codable models that match your Supabase tables.

**Usage:**
1. Copy the template
2. Replace `[Item]` with your model name (e.g., `Expense`, `Asset`)
3. Update property names to match your database columns
4. Update CodingKeys to map Swift names to database column names

### 2. ServiceTemplate.swift
Template for creating service classes that handle database operations.

**Usage:**
1. Copy the template
2. Replace `[Feature]` with your feature name (e.g., `Expense`, `Asset`)
3. Replace `[Item]` with your model name
4. Replace `[table_name]` with your Supabase table name
5. Add custom query methods as needed

### 3. ViewModelTemplate.swift
Template for creating ViewModels following MVVM pattern.

**Usage:**
1. Copy the template
2. Replace `[Feature]` with your feature name
3. Replace `[Item]` with your model name
4. Add feature-specific properties and methods

### 4. ListViewTemplate.swift
Template for creating list views with search and CRUD operations.

**Usage:**
1. Copy the template
2. Replace `[Feature]` with your feature name
3. Replace `[Item]` with your model name
4. Customize the row component
5. Update search logic

### 5. FormViewTemplate.swift
Template for creating form views for data entry.

**Usage:**
1. Copy the template
2. Replace `[Feature]` and `[Item]` placeholders
3. Add your form fields
4. Update validation logic
5. Customize sections as needed

## Quick Start Example

To create a new "Category" feature:

1. **Create Model:**
   ```swift
   // Models/Category/Category.swift
   // Copy from ModelTemplate.swift and replace [Item] with Category
   ```

2. **Create Service:**
   ```swift
   // Services/Supabase/CategoryService.swift
   // Copy from ServiceTemplate.swift
   // Replace [Feature] with Category, [table_name] with "categories"
   ```

3. **Create ViewModel:**
   ```swift
   // ViewModels/Category/CategoryViewModel.swift
   // Copy from ViewModelTemplate.swift
   ```

4. **Create Views:**
   ```swift
   // Views/Category/CategoryListView.swift
   // Copy from ListViewTemplate.swift
   
   // Views/Category/CategoryFormView.swift
   // Copy from FormViewTemplate.swift
   ```

## Placeholder Reference

| Placeholder | Replace With | Example |
|------------|-------------|---------|
| `[Item]` | Model name | `Expense`, `Asset` |
| `[Feature]` | Feature name | `Expense`, `Asset` |
| `[table_name]` | Database table name | `"expenses"`, `"assets"` |
| `field1`, `field2` | Actual property names | `amount`, `description` |

## Best Practices

1. Always update CodingKeys to match database column names
2. Keep ViewModels focused on a single responsibility
3. Use protocol-oriented programming for Services (testability)
4. Add validation logic in ViewModels, not Views
5. Create reusable components for repeated UI patterns

## Next Steps

After creating files from templates:
1. Update imports if needed
2. Implement custom business logic
3. Add proper error handling
4. Write unit tests
5. Update project structure documentation
