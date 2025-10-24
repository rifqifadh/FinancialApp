import SwiftUI

struct AccountsView: View {
  @Environment(RouterPath.self) private var routerPath
  
  @State private var viewModel = AccountsViewModel()
  @State private var showingAddAccount = false
  
  var body: some View {
      ViewStateView(state: viewModel.accountStateView) { state in
        ScrollView {
          if state.isEmpty {
            emptyStateView
          } else {
            content
          }
        }
      }
      .background(AppTheme.Colors.background)
      .navigationTitle("Accounts")
      .searchable(text: $viewModel.searchText, prompt: "Search accounts")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingAddAccount = true
          } label: {
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 20))
              .foregroundStyle(AppTheme.Colors.accent)
          }
        }
        
        if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
          ToolbarItem(placement: .cancellationAction) {
            Button("Clear Filters") {
              viewModel.clearFilters()
            }
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.accent)
          }
        }
      }
      .refreshable {
        await viewModel.refreshAccounts()
      }
      .task {
        if viewModel.accounts.isEmpty {
          await viewModel.loadAccounts()
        }
      }
      .sheet(isPresented: $showingAddAccount) {
        AccountFormView{
          Task {
            await viewModel.refreshAccounts()
          }
        }
      }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var content: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      // Summary Card
      if !viewModel.accounts.isEmpty {
        AccountSummaryCard(
          totalBalance: viewModel.totalBalance,
          accountCount: viewModel.totalAccounts,
          categoryBreakdown: viewModel.categoryBalances
        )
        .padding(.horizontal)
      }
      
      // Filter Chips
      if !viewModel.availableCategories.isEmpty {
        filterSection
      }
      
      // Accounts List
      accountsSection
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical)
  }
  
  // MARK: - Filter Section
  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppTheme.Spacing.sm) {
        FilterChip(
          icon: "line.3.horizontal.decrease.circle",
          text: "All",
          isSelected: viewModel.selectedCategory == nil
        ) {
          viewModel.selectCategory(nil)
        }
        
        ForEach(viewModel.availableCategories, id: \.self) { category in
          FilterChip(
            icon: category.icon,
            text: category.displayName,
            isSelected: viewModel.selectedCategory == category
          ) {
            viewModel.selectCategory(category)
          }
        }
      }
      .padding(.horizontal)
    }
  }
  
  // MARK: - Accounts Section
  private var accountsSection: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      //      if viewModel.selectedCategory == nil && viewModel.searchText.isEmpty {
      //        // Group by category
      //        ForEach(Array(viewModel.accountsByCategory.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { category in
      //          if let accounts = viewModel.accountsByCategory[category], !accounts.isEmpty {
      //            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
      //              // Category Header
      //              HStack {
      //                Image(systemName: category.icon)
      //                  .font(.system(size: 14))
      //                  .foregroundStyle(AppTheme.Colors.accentColor)
      //
      //                Text(category.displayName)
      //                  .font(AppTheme.Typography.bodyBold)
      //                  .foregroundStyle(AppTheme.Colors.primaryText)
      //
      //                Spacer()
      //
      //                Text("\(accounts.count)")
      //                  .font(AppTheme.Typography.caption)
      //                  .foregroundStyle(AppTheme.Colors.tertiaryText)
      //                  .padding(.horizontal, 8)
      //                  .padding(.vertical, 4)
      //                  .background(AppTheme.Colors.secondaryBackground)
      //                  .cornerRadius(AppTheme.CornerRadius.small)
      //              }
      //              .padding(.horizontal)
      //
      //              // Accounts in category
      //              VStack(spacing: AppTheme.Spacing.sm) {
      //                ForEach(accounts) { account in
      //                  AccountCard(account: account) {
      //                    // Handle account tap
      //                  }
      //                }
      //              }
      //              .padding(.horizontal)
      //            }
      //          }
      //        }
      //      } else {
      // Flat list when filtering
      VStack(spacing: AppTheme.Spacing.sm) {
        ForEach(viewModel.filteredAccounts) { account in
          AccountCard(account: account) {
            routerPath.navigate(to: .accountDetail(id: account.id))
          }
        }
      }
      .padding(.horizontal)
      //            }
      //      }
    }
  }
  
  // MARK: - Empty State View
  private var emptyStateView: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      Image(systemName: "wallet.pass")
        .font(.system(size: 64))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        Text("No Accounts Yet")
          .font(AppTheme.Typography.financialLarge)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        Text("Add your first account to start tracking your finances")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.secondaryText)
          .multilineTextAlignment(.center)
      }
      
      Button {
        showingAddAccount = true
      } label: {
        Label("Add Account", systemImage: "plus.circle.fill")
          .font(AppTheme.Typography.bodyBold)
          .foregroundStyle(.white)
          .padding(.horizontal, AppTheme.Spacing.lg)
          .padding(.vertical, AppTheme.Spacing.md)
          .background(AppTheme.Colors.accent)
          .cornerRadius(AppTheme.CornerRadius.medium)
      }
    }
    .padding()
  }
  
  
  // MARK: - No Results View
  private var noResultsView: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 48))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        Text("No Results Found")
          .font(AppTheme.Typography.financialLarge)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        Text("Try adjusting your filters or search")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.secondaryText)
      }
      
      Button("Clear Filters") {
        viewModel.clearFilters()
      }
      .font(AppTheme.Typography.bodyBold)
      .foregroundStyle(AppTheme.Colors.accent)
      .padding(.horizontal, AppTheme.Spacing.lg)
      .padding(.vertical, AppTheme.Spacing.sm)
      .background(AppTheme.Colors.accent.opacity(0.1))
      .cornerRadius(AppTheme.CornerRadius.medium)
    }
    .padding()
  }
}

// MARK: - Preview
#Preview {
  AccountsView()
}
