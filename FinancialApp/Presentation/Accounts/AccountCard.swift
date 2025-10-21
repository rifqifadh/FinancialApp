import SwiftUI

struct AccountCard: View {
    let account: AccountModel
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: account.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                }

                // Account Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(account.category.displayName)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)

                        if let accountNumber = account.accountNumber {
                            Text("•")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.tertiaryText)

                            Text(accountNumber)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.tertiaryText)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Balance
                VStack(alignment: .trailing, spacing: 4) {
                    Text(account.finalBalance.toCurrency())
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    if account.balanceChange != 0 {
                        HStack(spacing: 2) {
                            Image(systemName: account.balanceChange > 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 10, weight: .semibold))

                            Text(abs(account.balanceChange).toCurrency())
                                .font(AppTheme.Typography.caption)
                        }
                        .foregroundStyle(account.balanceChange > 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Account Card
struct AccountCardCompact: View {
    let account: AccountModel
    var showBalance: Bool = true

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Icon
            Image(systemName: account.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 32, height: 32)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .clipShape(Circle())

            // Name
            Text(account.name)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineLimit(1)

            Spacer()

            // Balance (optional)
            if showBalance {
                Text(account.finalBalance.toCurrency())
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Account Summary Card
struct AccountSummaryCard: View {
    let totalBalance: Int
    let accountCount: Int
    let categoryBreakdown: [AccountCategory: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(totalBalance.toCurrency())
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Accounts")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text("\(accountCount)")
                    .font(AppTheme.Typography.financialLarge)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }

            // Category Breakdown
//            if !categoryBreakdown.isEmpty {
//                Divider()
//                    .background(AppTheme.Colors.divider)
//
//                VStack(spacing: AppTheme.Spacing.sm) {
//                    ForEach(Array(categoryBreakdown.keys.sorted(by: { categoryBreakdown[$0]! > categoryBreakdown[$1]! })), id: \.self) { category in
//                        if let balance = categoryBreakdown[category] {
//                            HStack {
//                                Image(systemName: category.icon)
//                                    .font(.system(size: 14))
//                                    .foregroundStyle(AppTheme.Colors.accentColor)
//                                    .frame(width: 20)
//
//                                Text(category.displayName)
//                                    .font(AppTheme.Typography.caption)
//                                    .foregroundStyle(AppTheme.Colors.secondaryText)
//
//                                Spacer()
//
//                                Text(balance.toCurrency())
//                                    .font(AppTheme.Typography.caption.weight(.semibold))
//                                    .foregroundStyle(AppTheme.Colors.primaryText)
//
//                                Text("(\(Int((Double(balance) / Double(totalBalance)) * 100))%)")
//                                    .font(AppTheme.Typography.caption)
//                                    .foregroundStyle(AppTheme.Colors.tertiaryText)
//                            }
//                        }
//                    }
//                }
//            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Previews
#Preview("Account Card") {
    VStack(spacing: 16) {
        AccountCard(account: .mockBank)
        AccountCard(account: .mockEWallet)
        AccountCard(account: .mockCash)
    }
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Account Card Compact") {
    VStack(spacing: 12) {
        AccountCardCompact(account: .mockBank)
        AccountCardCompact(account: .mockEWallet, showBalance: false)
    }
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Account Summary Card") {
    AccountSummaryCard(
        totalBalance: 15000000,
        accountCount: 5,
        categoryBreakdown: [
            .bank: 10000000,
            .eWallet: 3000000,
            .cash: 2000000
        ]
    )
    .padding()
    .background(AppTheme.Colors.background)
}
