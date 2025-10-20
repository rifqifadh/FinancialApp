//
//  FilterChip.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

struct FilterChip: View {
  // MARK: - Properties
  let icon: String
  let text: String
  let isSelected: Bool
  var action: (() -> Void)? = nil

  // MARK: - Body
  var body: some View {
    HStack(spacing: AppTheme.Spacing.xs) {
      Image(systemName: icon)
        .font(.system(size: 12))
      Text(text)
        .font(AppTheme.Typography.caption)
    }
    .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
    .padding(.horizontal, AppTheme.Spacing.md)
    .padding(.vertical, AppTheme.Spacing.sm)
    .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
    .cornerRadius(AppTheme.CornerRadius.large)
    .onTapGesture {
      action?()
    }
  }
}

// MARK: - Convenience Initializers
extension FilterChip {
  /// Creates a filter chip without tap action (for use inside buttons/menus)
  init(icon: String, text: String, isSelected: Bool) {
    self.icon = icon
    self.text = text
    self.isSelected = isSelected
    self.action = nil
  }
}

// MARK: - Preview
#Preview("Selected Chip") {
  VStack(spacing: AppTheme.Spacing.md) {
    FilterChip(icon: "calendar", text: "Oct 2025", isSelected: true)
    FilterChip(icon: "tag.fill", text: "Food & Dining", isSelected: true)
    FilterChip(icon: "arrow.down.circle.fill", text: "Expenses", isSelected: true)
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Unselected Chip") {
  VStack(spacing: AppTheme.Spacing.md) {
    FilterChip(icon: "calendar", text: "Sep 2025", isSelected: false)
    FilterChip(icon: "tag.fill", text: "Shopping", isSelected: false)
    FilterChip(icon: "arrow.up.circle.fill", text: "Income", isSelected: false)
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("With Actions") {
  VStack(spacing: AppTheme.Spacing.md) {
    FilterChip(
      icon: "calendar",
      text: "Oct 2025",
      isSelected: true,
      action: { print("Calendar tapped") }
    )
    FilterChip(
      icon: "xmark.circle.fill",
      text: "Clear Filter",
      isSelected: false,
      action: { print("Clear tapped") }
    )
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Horizontal Scroll") {
  ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: AppTheme.Spacing.sm) {
      FilterChip(icon: "calendar", text: "Oct 2025", isSelected: true)
      FilterChip(icon: "tag.fill", text: "Food & Dining", isSelected: true)
      FilterChip(icon: "creditcard.fill", text: "BCA", isSelected: false)
      FilterChip(icon: "arrow.down.circle.fill", text: "Expenses", isSelected: false)
      FilterChip(icon: "arrow.up.circle.fill", text: "Income", isSelected: false)
    }
    .padding(.horizontal, AppTheme.Spacing.lg)
  }
  .background(AppTheme.Colors.background)
}

#Preview("Dark Mode") {
  VStack(spacing: AppTheme.Spacing.md) {
    FilterChip(icon: "calendar", text: "Oct 2025", isSelected: true)
    FilterChip(icon: "tag.fill", text: "Food & Dining", isSelected: true)
    FilterChip(icon: "creditcard.fill", text: "BCA", isSelected: false)
  }
  .padding()
  .background(AppTheme.Colors.background)
  .preferredColorScheme(.dark)
}
