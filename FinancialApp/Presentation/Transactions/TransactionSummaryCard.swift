//
//  TransactionSummaryCard.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

struct TransactionSummaryCard: View {
  // MARK: - Properties
  let netAmount: Int
  let totalIncome: Int
  let totalExpenses: Int
  let selectedMonth: Date
  let transactionCount: Int

  // MARK: - Body
  var body: some View {
    VStack(spacing: AppTheme.Spacing.sm) {
      // Net Balance - Main Focus
      HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Net Balance")
            .font(AppTheme.Typography.caption)
            .foregroundColor(AppTheme.Colors.secondaryText)

          Text(netAmount.toCurrency())
            .font(AppTheme.Typography.financialLarge)
            .foregroundColor(netAmount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "calendar")
              .font(.system(size: 10))
            Text(selectedMonth.formatted("MMM yyyy"))
              .font(.system(size: 11))
          }
          .foregroundColor(AppTheme.Colors.tertiaryText)

          Text("\(transactionCount) items")
            .font(.system(size: 10))
            .foregroundColor(AppTheme.Colors.tertiaryText)
        }
      }

      // Income & Expenses - Compact Row
      HStack(spacing: AppTheme.Spacing.md) {
        HStack(spacing: AppTheme.Spacing.xs) {
          Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 12))
            .foregroundColor(AppTheme.Colors.profit)
          Text(totalIncome.toCurrency())
            .font(AppTheme.Typography.footnote)
            .foregroundColor(AppTheme.Colors.profit)
        }

        Rectangle()
          .fill(AppTheme.Colors.divider)
          .frame(width: 1, height: 12)

        HStack(spacing: AppTheme.Spacing.xs) {
          Image(systemName: "arrow.down.circle.fill")
            .font(.system(size: 12))
            .foregroundColor(AppTheme.Colors.loss)
          Text(totalExpenses.toCurrency())
            .font(AppTheme.Typography.footnote)
            .foregroundColor(AppTheme.Colors.loss)
        }

        Spacer()
      }
    }
    .padding(AppTheme.Spacing.md)
    .background(
      LinearGradient(
        colors: [
          AppTheme.Colors.primary.opacity(0.08),
          AppTheme.Colors.cardBackground
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: AppTheme.Shadows.card, radius: 6, y: 3)
  }
}

// MARK: - Preview
#Preview("Positive Balance") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionSummaryCard(
      netAmount: 5_000_000,
      totalIncome: 10_000_000,
      totalExpenses: 5_000_000,
      selectedMonth: Date(),
      transactionCount: 24
    )
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Negative Balance") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionSummaryCard(
      netAmount: -2_000_000,
      totalIncome: 3_000_000,
      totalExpenses: 5_000_000,
      selectedMonth: Date(),
      transactionCount: 18
    )
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Zero Balance") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionSummaryCard(
      netAmount: 0,
      totalIncome: 5_000_000,
      totalExpenses: 5_000_000,
      selectedMonth: Date(),
      transactionCount: 12
    )
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Dark Mode") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionSummaryCard(
      netAmount: 5_000_000,
      totalIncome: 10_000_000,
      totalExpenses: 5_000_000,
      selectedMonth: Date(),
      transactionCount: 24
    )
  }
  .padding()
  .background(AppTheme.Colors.background)
  .preferredColorScheme(.dark)
}
