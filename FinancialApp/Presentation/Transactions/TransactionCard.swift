//
//  TransactionCard.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

struct TransactionCard: View {
  let transaction: TransactionModel

  var body: some View {
      HStack(alignment: .center, spacing: AppTheme.Spacing.md) {
        // Category Icon
        Circle()
          .fill(transaction.type.color.opacity(0.15))
          .frame(width: 32, height: 32)
          .overlay(
            Image(systemName: transaction.category?.iconName ?? transaction.type.icon)
              .foregroundColor(transaction.type.color)
              .font(.system(size: 14))
          )
        
        // Transaction Details
        VStack(alignment: .leading, spacing: 4) {
          Text(transaction.description)
            .font(AppTheme.Typography.bodyBold)
            .foregroundColor(AppTheme.Colors.primaryText)
            .lineLimit(1)
            .truncationMode(.tail)
          
          Text(transaction.accountName)
            .font(AppTheme.Typography.caption)
            .foregroundColor(AppTheme.Colors.tertiaryText)
            .lineLimit(1)
            .truncationMode(.tail)
          
          HStack(spacing: AppTheme.Spacing.md) {
            // Transaction Type Badge
            if let category = transaction.category {
              Text(category.name)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .lineLimit(1)
                .truncationMode(.tail)
            }
            Text(transaction.type.label)
              .font(.system(size: 10, weight: .semibold))
              .foregroundColor(transaction.type.color)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(transaction.type.color.opacity(0.15))
              .cornerRadius(4)
              .fixedSize()
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        
        Spacer(minLength: AppTheme.Spacing.sm)
        
        // Amount
        VStack(alignment: .trailing, spacing: 2) {
          Text(transaction.amount.toCurrency())
            .font(AppTheme.Typography.bodySmallBold)
            .foregroundColor(transaction.type.amountColor)
            .lineLimit(1)
            .fixedSize()
          
          Text(transaction.spentAt.formatTime())
            .font(.system(size: 10))
            .foregroundColor(AppTheme.Colors.tertiaryText)
            .fixedSize()
        }
      }
    .padding(AppTheme.Spacing.md)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: AppTheme.Shadows.card, radius: 4, y: 2)
  }
}

// MARK: - Preview
#Preview("Expense") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionCard(transaction: TransactionModel.mockExpenses[0])
    TransactionCard(transaction: TransactionModel.mockExpenses[1])
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Income") {
  VStack(spacing: AppTheme.Spacing.md) {
    TransactionCard(transaction: TransactionModel.mockIncome[0])
    TransactionCard(transaction: TransactionModel.mockIncome[1])
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("All Types") {
  ScrollView {
    VStack(spacing: AppTheme.Spacing.md) {
      ForEach(TransactionModel.mockList.prefix(8), id: \.id) { transaction in
        TransactionCard(transaction: transaction)
      }
    }
    .padding()
  }
  .background(AppTheme.Colors.background)
}

#Preview("Dark Mode") {
  VStack(spacing: AppTheme.Spacing.md) {
    ForEach(TransactionModel.mockList.prefix(4), id: \.id) { transaction in
      TransactionCard(transaction: transaction)
    }
  }
  .padding()
  .background(AppTheme.Colors.background)
  .preferredColorScheme(.dark)
}
