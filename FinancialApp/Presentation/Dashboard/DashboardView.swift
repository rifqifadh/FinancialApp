import SwiftUI

struct DashboardView: View {
  @Environment(RouterPath.self) var routerPath
  
  @State private var viewModel = DashboardViewModel()
  @State private var isFirstLoad = true
  
  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.lg) {
        // Header with greeting
        headerSection
        
        // Financial Overview Card
        financialOverviewCard
          .padding(.horizontal)
        
        // Quick Actions Menu
        quickActionsSection
          .padding(.horizontal)
        
        // Categories Overview
        categoriesOverviewSection
          .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .task {
      if isFirstLoad {
        await viewModel.loadSummary()
        isFirstLoad = false
      }
    }
    .background(AppTheme.Colors.background)
    .navigationTitle("Dashboard")
    .navigationBarTitleDisplayMode(.large)
  }
  
  // MARK: - Header Section
  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Welcome back!")
        .font(AppTheme.Typography.caption)
        .foregroundStyle(AppTheme.Colors.secondaryText)
      
      Text("Financial Overview")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
  }
  
  // MARK: - Financial Overview Card
  private var financialOverviewCard: some View {
    ViewStateView(state: viewModel.summaryState) { data in
      FinancialOverviewCard(totalAssets: 1000000, totalIncome: data.totalIncome, totalExpense: data.totalExpense)
    } emptyView: {
      FinancialOverviewCard.empty()
    } loadingView: {
      FinancialOverviewCard.empty().redacted(reason: .placeholder)
    } errorView: { _ in
      FinancialOverviewCard.empty()
    }
  }
  
  // MARK: - Quick Actions Section
  private var quickActionsSection: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Quick Access")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: AppTheme.Spacing.md) {
        // Accounts
        QuickActionCard(
          icon: "wallet.pass.fill",
          title: "Accounts",
          subtitle: "\(mockAccountsCount) accounts",
          color: AppTheme.Colors.accent
        ) {
          // Navigate to accounts - handled by tab
          routerPath.navigate(to: .accounts)
        }
        
        // Investments
        QuickActionCard(
          icon: "chart.line.uptrend.xyaxis",
          title: "Investments",
          subtitle: "\(mockInvestmentsCount) investments",
          color: Color.purple
        ) {
          // Navigate to investments - handled by tab
          routerPath.navigate(to: .investments)
        }
        
        // Transactions
        QuickActionCard(
          icon: "list.bullet.rectangle",
          title: "Transactions",
          subtitle: "\(mockTransactionsCount) this month",
          color: Color.orange
        ) {
          // Navigate to transactions - handled by tab
        }
        
        // Reports
        QuickActionCard(
          icon: "chart.bar.fill",
          title: "Reports",
          subtitle: "View insights",
          color: Color.green
        ) {
          // Future: Navigate to reports
        }
      }
    }
  }
  
  // MARK: - Categories Overview Section
  private var categoriesOverviewSection: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Top Spending Categories")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        ForEach(mockTopCategories, id: \.name) { category in
          CategorySpendingRow(
            name: category.name,
            amount: category.amount,
            percentage: category.percentage,
            color: category.color
          )
        }
      }
    }
  }
  
  // MARK: - Mock Data
  private let mockTotalAssets = 15604841
  private let mockAccountsCount = 8
  private let mockInvestmentsCount = 5
  private let mockTransactionsCount = 47
  
  private let mockRecentActivities = [
    RecentActivity(id: "1", title: "Salary", category: "Income", amount: 8000000, date: Date(), isIncome: true),
    RecentActivity(id: "2", title: "Groceries", category: "Food", amount: 350000, date: Date().addingTimeInterval(-86400), isIncome: false),
    RecentActivity(id: "3", title: "Dividend", category: "Investment", amount: 100000, date: Date().addingTimeInterval(-172800), isIncome: true),
    RecentActivity(id: "4", title: "Restaurant", category: "Food", amount: 250000, date: Date().addingTimeInterval(-259200), isIncome: false)
  ]
  
  private let mockTopCategories = [
    TopCategory(name: "Food & Dining", amount: 2500000, percentage: 0.48, color: Color.red),
    TopCategory(name: "Transportation", amount: 1200000, percentage: 0.23, color: Color.blue),
    TopCategory(name: "Shopping", amount: 950000, percentage: 0.18, color: Color.purple),
    TopCategory(name: "Entertainment", amount: 584159, percentage: 0.11, color: Color.orange)
  ]
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
  let icon: String
  let title: String
  let subtitle: String
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: AppTheme.Spacing.md) {
        ZStack {
          Circle()
            .fill(color.opacity(0.1))
            .frame(width: 56, height: 56)
          
          Image(systemName: icon)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(color)
        }
        
        VStack(spacing: 4) {
          Text(title)
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          Text(subtitle)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(AppTheme.Spacing.md)
      .background(AppTheme.Colors.cardBackground)
      .cornerRadius(AppTheme.CornerRadius.medium)
      .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Recent Activity Row
struct RecentActivityRow: View {
  let activity: RecentActivity
  
  var body: some View {
    HStack(spacing: AppTheme.Spacing.md) {
      // Icon
      ZStack {
        Circle()
          .fill(activity.isIncome ? AppTheme.Colors.profit.opacity(0.1) : AppTheme.Colors.loss.opacity(0.1))
          .frame(width: 40, height: 40)
        
        Image(systemName: activity.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(activity.isIncome ? AppTheme.Colors.profit : AppTheme.Colors.loss)
      }
      
      // Info
      VStack(alignment: .leading, spacing: 2) {
        Text(activity.title)
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        HStack(spacing: 6) {
          Text(activity.category)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text("•")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
          
          Text(formatDate(activity.date))
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
      }
      
      Spacer()
      
      // Amount
      Text(activity.amount.toCurrency())
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(activity.isIncome ? AppTheme.Colors.profit : AppTheme.Colors.loss)
    }
    .padding(AppTheme.Spacing.md)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter.string(from: date)
  }
}

// MARK: - Category Spending Row
struct CategorySpendingRow: View {
  let name: String
  let amount: Int
  let percentage: Double
  let color: Color
  
  var body: some View {
    VStack(spacing: 6) {
      HStack {
        HStack(spacing: 8) {
          Circle()
            .fill(color)
            .frame(width: 10, height: 10)
          
          Text(name)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.Colors.primaryText)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 2) {
          Text(amount.toCurrency())
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.Colors.primaryText)
          
          Text("\(Int(percentage * 100))%")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
      }
      
      // Progress Bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Rectangle()
            .fill(AppTheme.Colors.secondaryBackground)
            .frame(height: 4)
          
          Rectangle()
            .fill(color)
            .frame(width: geometry.size.width * percentage, height: 4)
        }
      }
      .frame(height: 4)
    }
    .padding(AppTheme.Spacing.md)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
  }
}

// MARK: - Models
struct RecentActivity {
  let id: String
  let title: String
  let category: String
  let amount: Int
  let date: Date
  let isIncome: Bool
}

struct TopCategory {
  let name: String
  let amount: Int
  let percentage: Double
  let color: Color
}

// MARK: - Preview
#Preview {
  DashboardView()
    .environment(RouterPath())
}
