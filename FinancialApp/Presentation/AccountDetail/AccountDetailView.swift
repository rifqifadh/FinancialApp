import SwiftUI

struct AccountDetailView: View {
  let accountId: String
  @State private var viewModel = AccountDetailViewModel()
  @State private var showCopiedAlert = false
  @State private var copiedText = ""
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.lg) {
        if let account = viewModel.account {
          // Header Card
          accountHeaderCard(account)
            .padding(.horizontal)
          
          // Transaction Summary
          if !viewModel.transactions.isEmpty {
            AccountTransactionSummaryCard(
              totalIncome: viewModel.totalIncome,
              totalExpense: viewModel.totalExpense,
              netAmount: viewModel.netAmount,
              transactionCount: viewModel.filteredTransactions.count
            )
            .padding(.horizontal)
          }
          
          // Filter Chips
          filterSection
            .padding(.horizontal)
          
          // Transactions List
          transactionsSection
        } else {
          loadingView
        }
      }
      .padding(.vertical)
    }
    .background(AppTheme.Colors.background)
    .navigationTitle(viewModel.account?.name ?? "Account Detail")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          viewModel.showEditAccount()
        } label: {
          Image(systemName: "pencil.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(AppTheme.Colors.accent)
        }
      }
    }
    .refreshable {
      await viewModel.refreshAll(accountId: accountId)
    }
    .task {
      await viewModel.loadAccount(id: accountId)
      await viewModel.loadTransactions(accountId: accountId)
    }
    .sheet(isPresented: $viewModel.showEditSheet) {
      if let account = viewModel.account {
        AccountFormView(mode: .edit(account)) {
          Task {
            await viewModel.refreshAll(accountId: accountId)
          }
        }
      }
    }
    .overlay(alignment: .bottom) {
      if showCopiedAlert {
        HStack(spacing: 8) {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(AppTheme.Colors.profit)
          
          Text("Copied to clipboard")
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: showCopiedAlert)
      }
    }
  }
  
  // MARK: - Account Header Card
  private func accountHeaderCard(_ account: AccountModel) -> some View {
    VStack(spacing: AppTheme.Spacing.md) {
      HStack {
        // Icon
        ZStack {
          Circle()
            .fill(AppTheme.Colors.accent.opacity(0.1))
            .frame(width: 56, height: 56)
          
          Image(systemName: account.icon)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.accent)
        }
        
        VStack(alignment: .leading, spacing: 8) {
          Text(account.name)
            .font(AppTheme.Typography.financialMedium)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          // Account Number with Copy Button
          if let accountNumber = account.accountNumber {
            HStack(spacing: 8) {
              Text(accountNumber)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryText)
              
              Button {
                copyToClipboard(
                  """
                  \(account.name) 
                  No: \(accountNumber)
                  """
                )
              } label: {
                Image(systemName: "doc.on.doc")
                  .font(.system(size: 12))
                  .foregroundStyle(AppTheme.Colors.accent)
              }
              .buttonStyle(.plain)
            }
          }
          
          Text(account.category.displayName)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        
        Spacer()
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
      
      // Balance Info
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Current Balance")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(account.finalBalance.toCurrency())
            .font(AppTheme.Typography.largeTitle)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        Spacer()
        
        if account.balanceChange != 0 {
          VStack(alignment: .trailing, spacing: 4) {
            Text("Change")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            HStack(spacing: 4) {
              Image(systemName: account.balanceChange > 0 ? "arrow.up" : "arrow.down")
                .font(.system(size: 12, weight: .bold))
              
              Text(abs(account.balanceChange).toCurrency())
                .font(AppTheme.Typography.bodyBold)
            }
            .foregroundStyle(account.balanceChange > 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
          }
        }
      }
      
      // Additional Info
      VStack(spacing: AppTheme.Spacing.sm) {
        HStack {
          Text("Currency")
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Spacer()
          
          Text(account.currency)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        HStack {
          Text("Initial Balance")
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Spacer()
          
          Text(account.initialBalance.toCurrency())
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        if let createdAt = account.createdAt {
          HStack {
            Text("Created")
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(createdAt.formatted("dd MMM yyyy"))
              .font(AppTheme.Typography.body)
              .foregroundStyle(AppTheme.Colors.primaryText)
          }
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
  
  // MARK: - Filter Section
  private var filterSection: some View {
    HStack(spacing: AppTheme.Spacing.sm) {
      ForEach(AccountDetailViewModel.TransactionFilter.allCases, id: \.self) { filter in
        FilterChip(
          icon: filter.icon,
          text: filter.rawValue,
          isSelected: viewModel.selectedFilter == filter
        ) {
          viewModel.setFilter(filter)
        }
      }
    }
  }
  
  // MARK: - Transactions Section
  private var transactionsSection: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      ViewStateView(state: viewModel.transactionsStateView) { _ in
        if viewModel.filteredTransactions.isEmpty {
          emptyTransactionsView
        } else {
          transactionsList
        }
      }
    }
    .padding(.horizontal)
  }
  
  private var transactionsList: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      ForEach(viewModel.sortedMonths, id: \.self) { month in
        if let transactions = viewModel.transactionsByMonth[month] {
          VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Month Header
            HStack {
              Text(month)
                .font(AppTheme.Typography.bodyBold)
                .foregroundStyle(AppTheme.Colors.primaryText)
              
              Spacer()
              
              Text("\(transactions.count)")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
            }
            
            // Transactions in month
            VStack(spacing: AppTheme.Spacing.sm) {
              ForEach(transactions, id: \.id) { transaction in
                AccountTransactionCard(transaction: transaction)
              }
            }
          }
        }
      }
    }
  }
  
  private var emptyTransactionsView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      Image(systemName: "list.bullet.rectangle")
        .font(.system(size: 48))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        Text("No Transactions")
          .font(AppTheme.Typography.financialMedium)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        Text("Transactions using this account will appear here")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.secondaryText)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.Spacing.xxl)
  }
  
  // MARK: - Loading View
  private var loadingView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      ProgressView()
        .scaleEffect(1.2)
      
      Text("Loading account details...")
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.top, 100)
  }
  
  // MARK: - Helper Functions
  private func copyToClipboard(_ text: String) {
    UIPasteboard.general.string = text
    
    copiedText = text
    showCopiedAlert = true
    
    // Auto-dismiss after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      showCopiedAlert = false
    }
  }
}

// MARK: - Preview
#Preview {
  NavigationStack {
    AccountDetailView(accountId: "2")
  }
}
