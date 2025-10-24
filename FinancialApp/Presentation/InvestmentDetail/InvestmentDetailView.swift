import SwiftUI

struct InvestmentDetailView: View {
  let investmentId: String
  @State private var viewModel = InvestmentDetailViewModel()
  @State private var selectedTab = 0
  @State private var showingAddTransaction = false
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.lg) {
        if let investment = viewModel.investment {
          // Header Card
          investmentHeaderCard(investment)
            .padding(.horizontal)
          
          // Tabs (only for stocks and similar investments)
          if shouldShowTransactions(investment.type) {
            tabSelector
              .padding(.horizontal)
            
            if selectedTab == 0 {
              overviewTab(investment)
            } else {
              transactionsTab
            }
          } else {
            // For non-stock investments, just show overview
            overviewTab(investment)
          }
        } else {
          loadingView
        }
      }
      .padding(.vertical)
    }
    .background(AppTheme.Colors.background)
    .navigationTitle(viewModel.investment?.name ?? "Investment Detail")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if shouldShowTransactions(viewModel.investment?.type) {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingAddTransaction = true
          } label: {
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 20))
              .foregroundStyle(AppTheme.Colors.accent)
          }
        }
      }
    }
    .refreshable {
      await viewModel.refreshAll(investmentId: investmentId)
    }
    .task {
      await viewModel.loadInvestment(id: investmentId)
      if shouldShowTransactions(viewModel.investment?.type) {
        await viewModel.loadTransactions(investmentId: investmentId)
      }
    }
    .sheet(isPresented: $showingAddTransaction) {
      if let investment = viewModel.investment {
        InvestmentTransactionFormView(investment: investment) {
          Task {
            await viewModel.refreshAll(investmentId: investmentId)
          }
        }
      }
    }
  }
  
  // MARK: - Investment Header Card
  private func investmentHeaderCard(_ investment: InvestmentModel) -> some View {
    VStack(spacing: AppTheme.Spacing.md) {
      HStack {
        // Icon
        ZStack {
          Circle()
            .fill(AppTheme.Colors.accent.opacity(0.1))
            .frame(width: 56, height: 56)
          
          Image(systemName: investment.icon)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.accent)
        }
        
        VStack(alignment: .leading, spacing: 4) {
          Text(investment.name)
            .font(AppTheme.Typography.financialMedium)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          Text(investment.type.displayName)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 2) {
          HStack(spacing: 4) {
            Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
              .font(.system(size: 12, weight: .bold))
            
            Text(String(format: "%.2f%%", abs(investment.profitPercentage)))
              .font(AppTheme.Typography.bodyBold)
          }
          .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
        }
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
      
      // Current Value
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Current Value")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(investment.currentValue.toCurrency())
            .font(AppTheme.Typography.largeTitle)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("Gain/Loss")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(investment.profit.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
  
  // MARK: - Tab Selector
  private var tabSelector: some View {
    HStack(spacing: 0) {
      Button {
        withAnimation {
          selectedTab = 0
        }
      } label: {
        Text("Overview")
          .font(AppTheme.Typography.body)
          .foregroundStyle(selectedTab == 0 ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText)
          .frame(maxWidth: .infinity)
          .padding(.vertical, AppTheme.Spacing.sm)
          .background(selectedTab == 0 ? AppTheme.Colors.accent.opacity(0.1) : Color.clear)
      }
      
      Button {
        withAnimation {
          selectedTab = 1
        }
      } label: {
        Text("Transactions")
          .font(AppTheme.Typography.body)
          .foregroundStyle(selectedTab == 1 ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText)
          .frame(maxWidth: .infinity)
          .padding(.vertical, AppTheme.Spacing.sm)
          .background(selectedTab == 1 ? AppTheme.Colors.accent.opacity(0.1) : Color.clear)
      }
    }
    .background(AppTheme.Colors.secondaryBackground)
    .cornerRadius(AppTheme.CornerRadius.small)
  }
  
  // MARK: - Overview Tab
  private func overviewTab(_ investment: InvestmentModel) -> some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Performance metrics for stocks
      if shouldShowTransactions(investment.type) {
        PerformanceSummaryCard(
          averageBuyPrice: viewModel.averageBuyPrice,
          currentPrice: viewModel.currentPrice,
          unrealizedProfit: viewModel.unrealizedProfit,
          realizedProfit: viewModel.realizedProfit,
          totalDividends: viewModel.totalDividends,
          totalReturn: viewModel.totalReturn
        )
        .padding(.horizontal)
        
        InvestmentTransactionSummaryCard(
          totalBuy: viewModel.totalBuyAmount,
          totalSell: viewModel.totalSellAmount,
          totalDividend: viewModel.totalDividends,
          buyUnits: viewModel.totalBuyUnits,
          sellUnits: viewModel.totalSellUnits,
          currentUnits: viewModel.currentHoldingUnits
        )
        .padding(.horizontal)
      }
      
      // Basic Info
      investmentInfoCard(investment)
        .padding(.horizontal)
    }
  }
  
  // MARK: - Transactions Tab
  private var transactionsTab: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      ViewStateView(state: viewModel.transactionsStateView) { _ in
        if viewModel.transactions.isEmpty {
          emptyTransactionsView
        } else {
          transactionsList
        }
      }
    }
    .padding(.horizontal)
  }
  
  private var transactionsList: some View {
    VStack(spacing: AppTheme.Spacing.sm) {
      ForEach(viewModel.transactions) { transaction in
        InvestmentTransactionCard(transaction: transaction) {
          // Handle transaction tap if needed
        }
      }
    }
  }
  
  private var emptyTransactionsView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      Image(systemName: "list.bullet.rectangle")
        .font(.system(size: 48))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      Text("No Transactions Yet")
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
      
      Button {
        showingAddTransaction = true
      } label: {
        Text("Add Transaction")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.accent)
          .padding(.horizontal, AppTheme.Spacing.lg)
          .padding(.vertical, AppTheme.Spacing.sm)
          .background(AppTheme.Colors.accent.opacity(0.1))
          .cornerRadius(AppTheme.CornerRadius.medium)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.Spacing.xxl)
  }
  
  // MARK: - Investment Info Card
  private func investmentInfoCard(_ investment: InvestmentModel) -> some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Investment Details")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        infoRow("Purchase Date", value: formatDate(investment.purchaseDate))
        infoRow("Initial Amount", value: investment.initialAmount.toCurrency())
        infoRow("Days Held", value: "\(investment.daysHeld) days")
        
        if let maturityDate = investment.maturityDate {
          infoRow("Maturity Date", value: formatDate(maturityDate))
          
          if let daysLeft = investment.daysUntilMaturity {
            if daysLeft > 0 {
              infoRow("Days to Maturity", value: "\(daysLeft) days")
            } else {
              infoRow("Status", value: "Matured")
            }
          }
        }
        
        if let rate = investment.interestRate {
          infoRow("Interest Rate", value: "\(String(format: "%.2f", rate))% p.a.")
        }
        
        if let accountName = investment.accountName {
          infoRow("Account", value: accountName)
        }
        
        if let notes = investment.notes, !notes.isEmpty {
          Divider()
            .background(AppTheme.Colors.divider)
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Text(notes)
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.primaryText)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
  
  private func infoRow(_ label: String, value: String) -> some View {
    HStack {
      Text(label)
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
      
      Spacer()
      
      Text(value)
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.primaryText)
    }
  }
  
  // MARK: - Loading View
  private var loadingView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      ProgressView()
        .scaleEffect(1.2)
      
      Text("Loading investment details...")
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top, 100)
  }
  
  // MARK: - Helper Functions
  private func shouldShowTransactions(_ type: InvestmentType?) -> Bool {
    guard let type = type else { return false }
    switch type {
    case .stocks, .reksaDanaSaham, .reksaDanaCampuran, .reksaDanaPasarUang, .reksaDanaPendapatanTetap:
      return true
    default:
      return false
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

// MARK: - Preview
#Preview {
  NavigationStack {
    InvestmentDetailView(investmentId: "1")
  }
}

#Preview {
  NavigationStack {
    InvestmentDetailView(investmentId: "2")
  }
}

#Preview {
  NavigationStack {
    InvestmentDetailView(investmentId: "3")
  }
}

#Preview {
  NavigationStack {
    InvestmentDetailView(investmentId: "4")
  }
}
