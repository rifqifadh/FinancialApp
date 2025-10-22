import SwiftUI

struct AccountTransactionCard: View {
    let transaction: TransactionModel
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Category Icon
                if let category = transaction.category {
                    ZStack {
                        Circle()
                            .fill(transactionColor.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: category.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(transactionColor)
                    }
                }

                // Transaction Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let category = transaction.category {
                            Text(category.name)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.secondaryText)
                        }

                        Text("•")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)

                      Text(formatDate(transaction.spentAt.toDate()))
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                    }
                }

                Spacer()

                // Amount
                Text(transaction.amount.toCurrency())
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundStyle(transactionColor)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }

    private var transactionColor: Color {
      transaction.type.rawValue == "Income" ? AppTheme.Colors.profit : AppTheme.Colors.loss
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Transaction Summary Card
struct AccountTransactionSummaryCard: View {
    let totalIncome: Int
    let totalExpense: Int
    let netAmount: Int
    let transactionCount: Int

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Net Amount
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Cash Flow")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(netAmount.toCurrency())
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundStyle(netAmount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Transactions")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text("\(transactionCount)")
                        .font(AppTheme.Typography.financialLarge)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }

            Divider()
                .background(AppTheme.Colors.divider)

            // Income & Expense Breakdown
            HStack(spacing: AppTheme.Spacing.lg) {
                // Income
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.profit)

                        Text("Income")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Text(totalIncome.toCurrency())
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundStyle(AppTheme.Colors.profit)
                }

                Spacer()

                // Expense
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.loss)

                        Text("Expense")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Text(totalExpense.toCurrency())
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundStyle(AppTheme.Colors.loss)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Previews
#Preview("Transaction Card") {
    VStack(spacing: 12) {
      if let mockTransaction = TransactionModel.mockList.first {
            AccountTransactionCard(transaction: mockTransaction)
        }
    }
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Transaction Summary Card") {
    AccountTransactionSummaryCard(
        totalIncome: 5000000,
        totalExpense: 3000000,
        netAmount: 2000000,
        transactionCount: 25
    )
    .padding()
    .background(AppTheme.Colors.background)
}
