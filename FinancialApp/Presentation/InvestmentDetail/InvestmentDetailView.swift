import SwiftUI
import Inject

struct InvestmentDetailView: View {
  let investmentId: String
  @State private var viewModel = InvestmentDetailViewModel()
  @State private var selectedTab = 0
  @State private var showingAddTransaction = false
  @State private var selectedQuickAction: QuickAction?
  @State private var transactionToEdit: InvestmentTransactionModel?
  @State private var showingUpdatePrice = false
  @State private var newPricePerUnit = ""

  @Environment(\.dismiss) private var dismiss
  
  @ObserveInjection var inject
  
  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.lg) {
        if let investment = viewModel.investment {
          // Maturity Banner (if applicable)
          if investment.isMatured && investment.maturityDate != nil {
            MaturityBannerView(investment: investment) {
              Task {
                await viewModel.refreshAll(investmentId: investmentId)
              }
            }
            .padding(.horizontal)
          }
          
          // Header Card
          investmentHeaderCard(investment)
            .padding(.horizontal)
          
          // Quick Actions
          QuickActionsView(investment: investment) { action in
            handleQuickAction(action, for: investment)
          }
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
    .sheet(item: $transactionToEdit) { transaction in
      if let investment = viewModel.investment {
        InvestmentTransactionFormView(
          investment: investment,
          existingTransaction: transaction
        ) {
          Task {
            await viewModel.refreshAll(investmentId: investmentId)
          }
        }
      }
    }
    .confirmationDialog(
      "Delete Transaction",
      isPresented: $viewModel.showingDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        Task {
          await viewModel.performDelete()
        }
      }
      Button("Cancel", role: .cancel) {
        viewModel.cancelDelete()
      }
    } message: {
      if let transaction = viewModel.transactionToDelete {
        Text("Are you sure you want to delete this \(transaction.type.rawValue.lowercased()) transaction of \(transaction.totalAmount.toCurrency())?")
      }
    }
    .sheet(isPresented: $showingUpdatePrice) {
      if let investment = viewModel.investment {
        updatePriceSheet(investment)
      }
    }
    .enableInjection()
  }
  
  // MARK: - Investment Header Card
  private func investmentHeaderCard(_ investment: InvestmentResponse) -> some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      // Name and Icon
      HStack(spacing: AppTheme.Spacing.md) {
        ZStack {
          Circle()
            .fill(AppTheme.Colors.accent.opacity(0.1))
            .frame(width: 48, height: 48)
          
          Image(systemName: investment.icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.accent)
        }
        
        VStack(alignment: .leading, spacing: 2) {
          Text(investment.name)
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          Text(investment.type.displayName)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
      }
      
      if (!shouldShowTransactions(investment.type)) {
        // Total Return (for stocks/mutual funds) or Total Profit (for deposito/bonds)
        Divider()
        
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.md) {
          VStack(alignment: .leading, spacing: 2) {
            Text(shouldShowTransactions(investment.type) ? "Total Return" : "Keuntungan")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            // For deposito/bonds: show simple profit
            Text(investment.profit.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
          }
          
          Spacer()
          
          VStack {
            Text("Imbal Hasil")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            HStack(spacing: 4) {
              // For deposito/bonds: use existing profit percentage
              Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
                .font(.system(size: 12, weight: .bold))
              Text(String(format: "%.2f%%", abs(investment.profitPercentage)))
                .font(AppTheme.Typography.bodyBold)
            }
            .foregroundStyle(investment.isProfit ? AppTheme.Colors.profit : AppTheme.Colors.loss)
          }
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
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
  private func overviewTab(_ investment: InvestmentResponse) -> some View {
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
          buyLot: viewModel.totalBuyLot,
          sellLot: viewModel.totalSellLot,
          currentLot: viewModel.currentHoldingLot
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
      // Filter UI
      TransactionFilterView(
        selectedFilter: $viewModel.selectedFilter,
        selectedSort: $viewModel.selectedSort,
        searchText: $viewModel.searchText
      )
      .padding(.horizontal)
      
      ViewStateView(state: viewModel.transactionsStateView) { _ in
        if viewModel.filteredAndSortedTransactions.isEmpty {
          if viewModel.transactions.isEmpty {
            emptyTransactionsView
          } else {
            noResultsView
          }
        } else {
          transactionsList
        }
      }
    }
  }
  
  private var transactionsList: some View {
    VStack(spacing: AppTheme.Spacing.sm) {
      ForEach(viewModel.filteredAndSortedTransactions) { transaction in
        InvestmentTransactionCard(transaction: transaction) {
          transactionToEdit = transaction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button(role: .destructive) {
            viewModel.confirmDelete(transaction)
          } label: {
            Label("Delete", systemImage: "trash")
          }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
          Button {
            transactionToEdit = transaction
          } label: {
            Label("Edit", systemImage: "pencil")
          }
          .tint(AppTheme.Colors.accent)
        }
      }
    }
    .padding(.horizontal)
  }
  
  private var noResultsView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 48))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      Text("No Matching Transactions")
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
      
      Button {
        withAnimation {
          viewModel.selectedFilter = .all
          viewModel.searchText = ""
        }
      } label: {
        Text("Clear Filters")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.accent)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.Spacing.xxl)
    .padding(.horizontal)
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
  private func investmentInfoCard(_ investment: InvestmentResponse) -> some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Additional Details")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)

      VStack(spacing: AppTheme.Spacing.sm) {
        infoRow("Nilai Sekarang", value: investment.currentValue.toCurrency())
        infoRow("Modal Investasi", value: investment.initialAmount.toCurrency())
        if let lot = investment.lot {
          infoRow("Lot", value: "\(Int(lot))")
        }

        // Price per unit (for stocks)
        if shouldShowTransactions(investment.type), let pricePerUnit = investment.pricePerUnit {
          HStack {
            Text("Current Price")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            Spacer()

            HStack(spacing: 8) {
              Text(pricePerUnit.toCurrency())
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.primaryText)

              Button {
                newPricePerUnit = String(pricePerUnit)
                showingUpdatePrice = true
              } label: {
                Image(systemName: "pencil.circle.fill")
                  .font(.system(size: 20))
                  .foregroundStyle(AppTheme.Colors.accent)
              }
            }
          }
        }

        infoRow("Purchase Date", value: formatDate(investment.purchaseDate))
        
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
        .font(AppTheme.Typography.caption)
        .foregroundStyle(AppTheme.Colors.secondaryText)
      
      Spacer()
      
      Text(value)
        .font(AppTheme.Typography.subheadline)
        .fontWeight(.semibold)
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
  private func handleQuickAction(_ action: QuickAction, for investment: InvestmentResponse) {
    switch action {
    case .buyMore:
      selectedQuickAction = action
      showingAddTransaction = true
    case .sell:
      selectedQuickAction = action
      showingAddTransaction = true
    case .dividend, .recordCoupon:
      selectedQuickAction = action
      showingAddTransaction = true
    case .updateValue:
      // Handled by MaturityBannerView
      break
    }
  }
  
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

  // MARK: - Update Price Sheet
  private func updatePriceSheet(_ investment: InvestmentResponse) -> some View {
    NavigationStack {
      Form {
        Section("Update Current Price") {
          TextField("Price Per Unit", text: $newPricePerUnit)
            .keyboardType(.numberPad)

          if let currentPrice = investment.pricePerUnit,
             let newPrice = Int(newPricePerUnit),
             newPrice != currentPrice {
            HStack {
              Text("Change")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

              Spacer()

              let change = newPrice - currentPrice
              let changePercentage = (Double(change) / Double(currentPrice)) * 100

              VStack(alignment: .trailing, spacing: 2) {
                Text(change.toCurrency())
                  .font(AppTheme.Typography.bodyBold)
                  .foregroundStyle(change >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)

                Text(String(format: "%.2f%%", changePercentage))
                  .font(AppTheme.Typography.caption)
                  .foregroundStyle(change >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
              }
            }
          }

          if let lot = investment.lot, let newPrice = Int(newPricePerUnit) {
            let newValue = lot * 100 * Double(newPrice)
            HStack {
              Text("New Total Value")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

              Spacer()

              Text(newValue.toCurrency())
                .font(AppTheme.Typography.bodyBold)
                .foregroundStyle(AppTheme.Colors.primaryText)
            }
          }
        }

        Section {
          Text("This will update the current price per unit for this investment. The total value will be recalculated based on your current holdings.")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
        }
      }
      .navigationTitle("Update Price")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            showingUpdatePrice = false
            newPricePerUnit = ""
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Update") {
            Task {
              await updatePrice(investment)
            }
          }
          .disabled(newPricePerUnit.isEmpty || Int(newPricePerUnit) == nil)
        }
      }
    }
  }

  private func updatePrice(_ investment: InvestmentResponse) async {
    guard let newPrice = Int(newPricePerUnit) else { return }

    await viewModel.updatePricePerUnit(investment, newPrice: newPrice)
    showingUpdatePrice = false
    newPricePerUnit = ""
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
