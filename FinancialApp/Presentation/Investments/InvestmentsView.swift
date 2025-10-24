import SwiftUI

struct InvestmentsView: View {
  @State private var viewModel = InvestmentsViewModel()
  @State private var showingAddInvestment = false
  
  @Environment(RouterPath.self) var routerPath
  
  var body: some View {
    ViewStateView(state: viewModel.investmentStateView) { state in
      ScrollView {
        if state.isEmpty {
          emptyStateView
        } else {
          
          content
        }
      }
    }
    .background(AppTheme.Colors.background)
    .navigationTitle("Investments")
    .searchable(text: $viewModel.searchText, prompt: "Search investments")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showingAddInvestment = true
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(AppTheme.Colors.accent)
        }
      }
      
      if viewModel.selectedType != nil || !viewModel.searchText.isEmpty {
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
      await viewModel.refreshInvestments()
    }
    .task {
      if viewModel.investments.isEmpty {
        await viewModel.loadInvestments()
      }
    }
    .sheet(isPresented: $showingAddInvestment) {
      InvestmentFormView {
        Task {
          await viewModel.refreshInvestments()
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var content: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      // Summary Card
      if !viewModel.investments.isEmpty {
        InvestmentSummaryCard(
          totalValue: viewModel.totalInvestmentValue,
          totalInitial: viewModel.totalInitialAmount,
          investmentCount: viewModel.totalInvestments,
          totalProfit: viewModel.totalProfit,
          totalProfitPercentage: viewModel.totalProfitPercentage
        )
        .padding(.horizontal)
      }
      
      // Type Overview (horizontal scroll)
      if !viewModel.availableTypes.isEmpty && viewModel.selectedType == nil {
        typeOverviewSection
      }
      
      // Filter Chips
      if !viewModel.availableTypes.isEmpty {
        filterSection
      }
      
      // Investments List
      investmentsSection
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical)
  }
  
  // MARK: - Type Overview Section
  private var typeOverviewSection: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
      Text("By Type")
        .font(AppTheme.Typography.bodyBold)
        .foregroundStyle(AppTheme.Colors.primaryText)
        .padding(.horizontal)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: AppTheme.Spacing.sm) {
          ForEach(viewModel.availableTypes, id: \.self) { type in
            if let value = viewModel.typeValues[type],
               let profit = viewModel.typeProfits[type] {
              let count = viewModel.investmentsByType[type]?.count ?? 0
              
              InvestmentTypeCard(
                type: type,
                value: value,
                profit: profit,
                count: count
              )
              .frame(width: 140)
              .onTapGesture {
                viewModel.selectType(type)
              }
            }
          }
        }
        .padding(.horizontal)
      }
    }
  }
  
  // MARK: - Filter Section
  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppTheme.Spacing.sm) {
        FilterChip(
          icon: "line.3.horizontal.decrease.circle",
          text: "All",
          isSelected: viewModel.selectedType == nil
        ) {
          viewModel.selectType(nil)
        }
        
        ForEach(viewModel.availableTypes, id: \.self) { type in
          FilterChip(
            icon: type.icon,
            text: type.shortName,
            isSelected: viewModel.selectedType == type
          ) {
            viewModel.selectType(type)
          }
        }
      }
      .padding(.horizontal)
    }
  }
  
  // MARK: - Investments Section
  private var investmentsSection: some View {
    VStack(spacing: AppTheme.Spacing.sm) {
      ForEach(viewModel.filteredInvestments) { investment in
//        NavigationLink(value: AppRouter.investmentDetail(id: investment.id)) {
          InvestmentCard(investment: investment)
          //          .onTapGesture {
          //            appNavigation.push(.investmentDetail(id: investment.id))
          //          }
//        }
      }
    }
    .padding(.horizontal)
    .navigationDestination(for: String.self) { investmentId in
      InvestmentDetailView(investmentId: investmentId)
    }
  }
  
  // MARK: - Empty State View
  private var emptyStateView: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 64))
        .foregroundStyle(AppTheme.Colors.tertiaryText)
      
      VStack(spacing: AppTheme.Spacing.sm) {
        Text("No Investments Yet")
          .font(AppTheme.Typography.financialLarge)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        Text("Start building your investment portfolio today")
          .font(AppTheme.Typography.body)
          .foregroundStyle(AppTheme.Colors.secondaryText)
          .multilineTextAlignment(.center)
      }
      
      Button {
        showingAddInvestment = true
      } label: {
        Label("Add Investment", systemImage: "plus.circle.fill")
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
}

// MARK: - Preview
#Preview {
  InvestmentsView()
}
