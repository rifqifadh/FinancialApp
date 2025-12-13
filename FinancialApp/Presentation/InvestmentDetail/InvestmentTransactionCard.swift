import SwiftUI

struct InvestmentTransactionCard: View {
  let transaction: InvestmentTransactionModel
  var onTap: (() -> Void)?
  
  var body: some View {
    Button(action: { onTap?() }) {
      HStack(spacing: AppTheme.Spacing.md) {
        // Icon
        Image(systemName: transaction.icon)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(iconColor)
          .frame(width: 44, height: 44)
          .background(iconColor.opacity(0.1))
          .clipShape(Circle())
        
        // Transaction Info
        VStack(alignment: .leading, spacing: 4) {
          Text(transaction.type.displayName)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          HStack(spacing: 8) {
            Text("\(String(format: "%.2f", transaction.lot)) lot")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            Text("•")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.tertiaryText)

            Text(transaction.pricePerUnit.toCurrency())
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          Text(formatDate(transaction.transactionDate))
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        
        Spacer()
        
        // Amount
        VStack(alignment: .trailing, spacing: 4) {
          Text(transaction.displayAmount.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(amountColor)
          
          if let notes = transaction.notes, !notes.isEmpty {
            Image(systemName: "note.text")
              .font(.system(size: 12))
              .foregroundStyle(AppTheme.Colors.tertiaryText)
          }
        }
      }
      .padding(AppTheme.Spacing.md)
      .background(AppTheme.Colors.cardBackground)
      .cornerRadius(AppTheme.CornerRadius.medium)
    }
    .buttonStyle(.plain)
  }
  
  private var iconColor: Color {
    switch transaction.type {
    case .buy:
      return AppTheme.Colors.loss
    case .sell, .dividend:
      return AppTheme.Colors.profit
    }
  }
  
  private var amountColor: Color {
    switch transaction.type {
    case .buy:
      return AppTheme.Colors.loss
    case .sell, .dividend:
      return AppTheme.Colors.profit
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

// MARK: - Transaction Summary Card
struct InvestmentTransactionSummaryCard: View {
  let totalBuy: Double
  let totalSell: Double
  let totalDividend: Double
  let buyLot: Int
  let sellLot: Int
  let currentLot: Int

  var body: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Lot Summary
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Current Holdings")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)

          Text("\(currentLot) Lot")
            .font(AppTheme.Typography.largeTitle)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        Spacer()
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
      
      // Transaction Summary
      VStack(spacing: AppTheme.Spacing.sm) {
        // Buy
        HStack {
          HStack(spacing: 8) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 16))
              .foregroundStyle(AppTheme.Colors.loss)
            
            Text("Total Bought")
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          Spacer()
          
          VStack(alignment: .trailing, spacing: 2) {
            Text(totalBuy.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(AppTheme.Colors.primaryText)

            Text("\(buyLot) Lot")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.tertiaryText)
          }
        }

        // Sell
        if sellLot > 0 {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.Colors.profit)

              Text("Total Sold")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
              Text(totalSell.toCurrency())
                .font(AppTheme.Typography.bodyBold)
                .foregroundStyle(AppTheme.Colors.primaryText)

              Text("\(sellLot) lot")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
          }
        }
        
        // Dividend
        if totalDividend > 0 {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.Colors.profit)
              
              Text("Total Dividends")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            Text(totalDividend.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(AppTheme.Colors.profit)
          }
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
}

// MARK: - Performance Summary Card
struct PerformanceSummaryCard: View {
  let averageBuyPrice: Double
  let currentPrice: Double
  let unrealizedProfit: Double
  let realizedProfit: Double
  let totalDividends: Double
  let totalReturn: Double
  
  var body: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Header
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Total Return")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          HStack(spacing: 8) {
            Text(totalProfitAmount.toCurrency())
              .font(AppTheme.Typography.largeTitle)
              .foregroundStyle(totalProfitAmount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
            
            HStack(spacing: 2) {
              Image(systemName: totalProfitAmount >= 0 ? "arrow.up" : "arrow.down")
                .font(.system(size: 12, weight: .bold))
              
              Text("\(totalReturn.toCurrency())")
                .font(AppTheme.Typography.bodyBold)
            }
            .foregroundStyle(totalProfitAmount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((totalProfitAmount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss).opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
          }
        }
        
        Spacer()
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
      
      // Price Info
      HStack(spacing: AppTheme.Spacing.lg) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Avg Buy Price")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(averageBuyPrice.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("Current Price")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(currentPrice.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
      }
      
      // Profit Breakdown
      VStack(spacing: AppTheme.Spacing.sm) {
        // Unrealized
        HStack {
          Text("Unrealized Gain/Loss")
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Spacer()
          
          Text(unrealizedProfit.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(unrealizedProfit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
        }
        
        // Realized
        if realizedProfit != 0 {
          HStack {
            Text("Realized Gain/Loss")
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(realizedProfit.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(realizedProfit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
          }
        }
        
        // Dividends
        if totalDividends > 0 {
          HStack {
            Text("Dividends")
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(totalDividends.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(AppTheme.Colors.profit)
          }
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
  
  private var totalProfitAmount: Double {
    unrealizedProfit + realizedProfit + totalDividends
  }
}

// MARK: - Previews
#Preview("Transaction Card") {
  VStack(spacing: 12) {
    InvestmentTransactionCard(transaction: .mockBuy1)
    InvestmentTransactionCard(transaction: .mockSell1)
    InvestmentTransactionCard(transaction: .mockDividend1)
  }
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Transaction Summary Card") {
  InvestmentTransactionSummaryCard(
    totalBuy: 5100000,
    totalSell: 1200000,
    totalDividend: 180000,
    buyLot: 500,
    sellLot: 100,
    currentLot: 400
  )
  .padding()
  .background(AppTheme.Colors.background)
}

#Preview("Performance Summary Card") {
  PerformanceSummaryCard(
    averageBuyPrice: 10200,
    currentPrice: 13000,
    unrealizedProfit: 1120000,
    realizedProfit: 180000,
    totalDividends: 180000,
    totalReturn: 29.41
  )
  .padding()
  .background(AppTheme.Colors.background)
}
