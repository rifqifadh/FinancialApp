# UI Design System - FinancialApp

This document outlines the UI design system and AppTheme usage patterns.

## AppTheme Structure

The app uses a centralized `AppTheme` struct for all styling:

### Colors

```swift
// Primary colors
AppTheme.Colors.primary
AppTheme.Colors.primaryLight
AppTheme.Colors.primaryDark

// Secondary colors
AppTheme.Colors.secondary
AppTheme.Colors.secondaryLight
AppTheme.Colors.secondaryDark

// Accent
AppTheme.Colors.accent

// Semantic colors for financial data
AppTheme.Colors.profit    // Green for gains
AppTheme.Colors.loss      // Red for losses
AppTheme.Colors.neutral   // Gray for neutral

// Backgrounds
AppTheme.Colors.background
AppTheme.Colors.secondaryBackground
AppTheme.Colors.tertiaryBackground

// Cards
AppTheme.Colors.cardBackground
AppTheme.Colors.elevatedCard

// Text
AppTheme.Colors.primaryText
AppTheme.Colors.secondaryText
AppTheme.Colors.tertiaryText

// Borders & Dividers
AppTheme.Colors.border
AppTheme.Colors.divider

// Charts
AppTheme.Colors.chartColors  // Array of 5 colors
```

### Typography

```swift
// Headers
AppTheme.Typography.largeTitle  // 34pt, bold, rounded
AppTheme.Typography.title1      // 28pt, bold, rounded
AppTheme.Typography.title2      // 22pt, bold, rounded
AppTheme.Typography.title3      // 20pt, semibold, rounded

// Body text
AppTheme.Typography.body           // 17pt, regular
AppTheme.Typography.bodyBold       // 17pt, semibold
AppTheme.Typography.bodySmall      // 14pt, regular
AppTheme.Typography.bodySmallBold  // 14pt, semibold

// Financial numbers (monospaced for alignment)
AppTheme.Typography.financialLarge   // 32pt, bold, monospaced
AppTheme.Typography.financialMedium  // 24pt, semibold, monospaced
AppTheme.Typography.financialSmall   // 17pt, medium, monospaced

// Supporting text
AppTheme.Typography.caption   // 12pt, regular
AppTheme.Typography.footnote  // 13pt, regular
```

### Spacing

```swift
AppTheme.Spacing.xs   // 4
AppTheme.Spacing.sm   // 8
AppTheme.Spacing.md   // 16
AppTheme.Spacing.lg   // 24
AppTheme.Spacing.xl   // 32
AppTheme.Spacing.xxl  // 48
```

### Corner Radius

```swift
AppTheme.CornerRadius.small   // 8
AppTheme.CornerRadius.medium  // 12
AppTheme.CornerRadius.large   // 16
AppTheme.CornerRadius.xlarge  // 24
```

### Shadows

```swift
AppTheme.Shadows.card      // Black 8% opacity
AppTheme.Shadows.elevated  // Black 12% opacity
```

## Card Component Pattern

Standard card layout:

```swift
VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
  // Card content
}
.padding(AppTheme.Spacing.lg)
.background(AppTheme.Colors.cardBackground)
.cornerRadius(AppTheme.CornerRadius.medium)
.shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
```

## Form Field Pattern

Standard form field layout:

```swift
VStack(alignment: .leading, spacing: 8) {
  Text("Field Label")
    .font(AppTheme.Typography.caption)
    .foregroundStyle(AppTheme.Colors.secondaryText)

  TextField("Placeholder", text: $value)
    .textFieldStyle(.plain)
    .font(AppTheme.Typography.body)
}
.padding(.vertical, 4)
```

## List Item Pattern

Standard list item with icon:

```swift
HStack(spacing: AppTheme.Spacing.md) {
  // Icon
  ZStack {
    Circle()
      .fill(AppTheme.Colors.accent.opacity(0.1))
      .frame(width: 48, height: 48)

    Image(systemName: iconName)
      .font(.system(size: 20, weight: .semibold))
      .foregroundStyle(AppTheme.Colors.accent)
  }

  // Content
  VStack(alignment: .leading, spacing: 4) {
    Text(title)
      .font(AppTheme.Typography.body)
      .foregroundStyle(AppTheme.Colors.primaryText)

    Text(subtitle)
      .font(AppTheme.Typography.caption)
      .foregroundStyle(AppTheme.Colors.tertiaryText)
  }

  Spacer()

  // Trailing content
  Text(value)
    .font(AppTheme.Typography.bodyBold)
    .foregroundStyle(AppTheme.Colors.primaryText)
}
.padding(AppTheme.Spacing.md)
.background(AppTheme.Colors.cardBackground)
.cornerRadius(AppTheme.CornerRadius.medium)
```

## Financial Value Display

For displaying currency amounts:

```swift
// Use Int extension for currency formatting
let amount: Int = 1234567
Text(amount.toCurrency())  // "Rp1.234.567"

// With custom symbol
Text(amount.toCurrency(symbol: "$"))  // "$1.234.567"

// For positive/negative amounts
Text(amount.toCurrency())
  .font(AppTheme.Typography.financialLarge)
  .foregroundStyle(amount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
```

## Empty State Pattern

```swift
ContentUnavailableView(
  "No {Items}",
  systemImage: "tray",
  description: Text("Add your first {item}")
)
```

## Loading Overlay Pattern

```swift
.overlay {
  if viewModel.isLoading {
    LoadingView(message: "Loading...")
  }
}
```

## Button Styles

```swift
// Primary action button
Button("Action") {
  // action
}
.font(AppTheme.Typography.bodyBold)
.foregroundStyle(.white)
.frame(maxWidth: .infinity)
.padding(AppTheme.Spacing.md)
.background(AppTheme.Colors.primary)
.cornerRadius(AppTheme.CornerRadius.medium)

// Secondary action button
Button("Action") {
  // action
}
.buttonStyle(.bordered)

// Plain button
Button("Action") {
  // action
}
.buttonStyle(.plain)
```

## Navigation Patterns

```swift
// Standard navigation
NavigationStack {
  // Content
}
.navigationTitle("Title")
.navigationBarTitleDisplayMode(.inline)
.toolbar {
  ToolbarItem(placement: .cancellationAction) {
    Button("Cancel") { dismiss() }
  }

  ToolbarItem(placement: .confirmationAction) {
    Button("Save") { /* save */ }
  }
}
```

## Picker Patterns

```swift
// Menu picker
Picker("Label", selection: $selectedValue) {
  ForEach(options, id: \.self) { option in
    HStack {
      Image(systemName: option.icon)
      Text(option.displayName)
    }
    .tag(option)
  }
}
.pickerStyle(.menu)
```

## Alert Patterns

```swift
.alert("Error", isPresented: $showError) {
  Button("OK", role: .cancel) {}
} message: {
  if let errorMessage = errorMessage {
    Text(errorMessage)
  }
}
```

## Reusable Component Checklist

When creating reusable UI components:

1. ✅ Use AppTheme for all colors, typography, spacing
2. ✅ Make the component configurable with parameters
3. ✅ Provide sensible defaults
4. ✅ Include #Preview with multiple examples
5. ✅ Use MARK comments to organize sections
6. ✅ Support both light and dark modes
7. ✅ Add accessibility labels where appropriate
