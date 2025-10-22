import SwiftUI

struct InvestmentCard: View {
    let investment: InvestmentModel
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: AppTheme.Spacing.md) {
                // Header
                HStack(spacing: AppTheme.Spacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.accent.opacity(0.1))
                            .frame(width: 48, height: 48)

                        Image(systemName: investment.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accent)
                    }

                    // Investment Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(investment.name)
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                            .lineLimit(1)

                        Text(investment.type.shortName)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                    }

                    Spacer()

                    // Profit indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
                                .font(.system(size: 10, weight: .bold))

                            Text(String(format: "%.2f%%", abs(investment.profitPercentage)))
                                .font(AppTheme.Typography.caption.weight(.semibold))
                        }
                        .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)

                        Text(investment.profit.toCurrency())
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                    }
                }

                // Divider
                Divider()
                    .background(AppTheme.Colors.divider)

                // Values
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Value")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        Text(investment.currentValue.toCurrency())
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Initial")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        Text(investment.initialAmount.toCurrency())
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }

                // Additional info
                if let maturityDate = investment.maturityDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.Colors.tertiaryText)

                        if let daysLeft = investment.daysUntilMaturity {
                            if daysLeft > 0 {
                                Text("Matures in \(daysLeft) days")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                            } else {
                                Text("Matured")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.profit)
                            }
                        }

                        Spacer()

                        if let rate = investment.interestRate {
                            Text("\(String(format: "%.2f", rate))% p.a.")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.accent)
                        }
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

// MARK: - Compact Investment Card
struct InvestmentCardCompact: View {
    let investment: InvestmentModel

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Icon
            Image(systemName: investment.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 32, height: 32)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .clipShape(Circle())

            // Name & Type
            VStack(alignment: .leading, spacing: 2) {
                Text(investment.name)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(1)

                Text(investment.type.shortName)
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }

            Spacer()

            // Value & Profit
            VStack(alignment: .trailing, spacing: 2) {
                Text(investment.currentValue.toCurrency())
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.primaryText)

                HStack(spacing: 2) {
                    Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
                        .font(.system(size: 8, weight: .bold))

                    Text(String(format: "%.1f%%", abs(investment.profitPercentage)))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Investment Summary Card
struct InvestmentSummaryCard: View {
    let totalValue: Int
    let totalInitial: Int
    let investmentCount: Int
    let totalProfit: Int
    let totalProfitPercentage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Portfolio")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(totalValue.toCurrency())
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Investments")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text("\(investmentCount)")
                        .font(AppTheme.Typography.financialLarge)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }

            // Profit/Loss
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Gain/Loss")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    HStack(spacing: 8) {
                        Text(totalProfit.toCurrency())
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundStyle(totalProfit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)

                        HStack(spacing: 2) {
                            Image(systemName: totalProfit >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 10, weight: .bold))

                            Text(String(format: "%.2f%%", abs(totalProfitPercentage)))
                                .font(AppTheme.Typography.caption.weight(.semibold))
                        }
                        .foregroundStyle(totalProfit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((totalProfit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss).opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.small)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Initial")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(totalInitial.toCurrency())
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Investment Type Card
struct InvestmentTypeCard: View {
    let type: InvestmentType
    let value: Int
    let profit: Int
    let count: Int

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.accent.opacity(0.1))
                    .clipShape(Circle())

                Spacer()

                Text("\(count)")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(type.shortName)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)

                Text(value.toCurrency())
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                HStack(spacing: 4) {
                    Image(systemName: profit >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 8, weight: .bold))

                    Text(profit.toCurrency())
                        .font(AppTheme.Typography.caption)
                }
                .foregroundStyle(profit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Previews
#Preview("Investment Card") {
    VStack(spacing: 16) {
        InvestmentCard(investment: .mockDeposito)
        InvestmentCard(investment: .mockStocks)
    }
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Investment Card Compact") {
    VStack(spacing: 12) {
        InvestmentCardCompact(investment: .mockDeposito)
        InvestmentCardCompact(investment: .mockStocks)
    }
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Investment Summary Card") {
    InvestmentSummaryCard(
        totalValue: 25000000,
        totalInitial: 20000000,
        investmentCount: 5,
        totalProfit: 5000000,
        totalProfitPercentage: 25.0
    )
    .padding()
    .background(AppTheme.Colors.background)
}

#Preview("Investment Type Card") {
    HStack(spacing: 12) {
        InvestmentTypeCard(
            type: .stocks,
            value: 10000000,
            profit: 2000000,
            count: 3
        )

        InvestmentTypeCard(
            type: .deposito,
            value: 5000000,
            profit: 250000,
            count: 2
        )
    }
    .padding()
    .background(AppTheme.Colors.background)
}
