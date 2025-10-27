//
//  TransactionView.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

struct TransactionView: View {
  // MARK: - ViewModel
  @State private var viewModel = TransactionsViewModel()
  
  // MARK: - Body
  var body: some View {
      ZStack {
        AppTheme.Colors.background
          .ignoresSafeArea()
        
          transactionsList
      }
      .task {
        await viewModel.loadTransactions()
      }
      .navigationTitle("Transactions")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(action: { viewModel.setSortOrder(.dateDescending) }) {
              HStack {
                Text("Newest First")
                Spacer()
                if viewModel.sortOrder == .dateDescending {
                  Image(systemName: "checkmark")
                }
              }
            }
            Button(action: { viewModel.setSortOrder(.dateAscending) }) {
              HStack {
                Text("Oldest First")
                Spacer()
                if viewModel.sortOrder == .dateAscending {
                  Image(systemName: "checkmark")
                }
              }
            }
            Button(action: { viewModel.setSortOrder(.amountDescending) }) {
              HStack {
                Text("Highest Amount")
                Spacer()
                if viewModel.sortOrder == .amountDescending {
                  Image(systemName: "checkmark")
                }
              }
            }
            Button(action: { viewModel.setSortOrder(.amountAscending) }) {
              HStack {
                Text("Lowest Amount")
                Spacer()
                if viewModel.sortOrder == .amountAscending {
                  Image(systemName: "checkmark")
                }
              }
            }
          } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
              .foregroundColor(AppTheme.Colors.primary)
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { viewModel.toggleFilterSheet() }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
              .foregroundColor(AppTheme.Colors.primary)
          }
        }
      }
      .sheet(isPresented: $viewModel.showFilterSheet) {
        TransactionFilterSheet(
          selectedMonth: $viewModel.selectedMonth,
          selectedType: $viewModel.selectedType,
          selectedCategoryId: $viewModel.selectedCategoryId,
          isPresented: $viewModel.showFilterSheet,
          availableCategories: viewModel.availableCategories
        )
      }
      .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
  }
  
  // MARK: - Summary Card
  private var summaryCard: some View {
    TransactionSummaryCard(
      netAmount: viewModel.netAmount,
      totalIncome: viewModel.totalIncome,
      totalExpenses: viewModel.totalExpenses,
      selectedMonth: viewModel.selectedMonth,
      transactionCount: viewModel.filteredTransactions.count
    )
  }
  
  // MARK: - Filter Bar
  private var filterBar: some View {
    // Month Selector
    Menu {
      ForEach(-6..<1) { monthOffset in
        Button(action: {
          viewModel.selectMonth(monthOffset)
        }) {
          Text((Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()).formatted("MMMM yyyy"))
        }
      }
    } label: {
      FilterChip(
        icon: "calendar",
        text: viewModel.selectedMonth.formatted("MMM yyyy"),
        isSelected: true
      )
    }
  }
  
  // MARK: - TransactionModel Type Tabs
  private var transactionTypeTabs: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppTheme.Spacing.sm) {
        typeTab(type: nil, label: "All", icon: "list.bullet")
        typeTab(type: .expense, label: "Expenses", icon: "arrow.down.circle.fill")
        typeTab(type: .income, label: "Income", icon: "arrow.up.circle.fill")
        typeTab(type: .transfer, label: "Transfers", icon: "arrow.left.arrow.right.circle.fill")
        typeTab(type: .split_bill, label: "Split Bills", icon: "person.2.fill")
      }
    }
  }
  
  private func typeTab(type: TransactionType?, label: String, icon: String) -> some View {
    Button(action: { viewModel.selectType(type) }) {
      HStack(spacing: AppTheme.Spacing.sm) {
        Image(systemName: icon)
          .font(.system(size: 12))
        Text(label)
          .font(AppTheme.Typography.caption)
      }
      .foregroundColor(viewModel.selectedType == type ? .white : AppTheme.Colors.primaryText)
      .padding(.horizontal, AppTheme.Spacing.lg)
      .padding(.vertical, AppTheme.Spacing.sm)
      .background(viewModel.selectedType == type ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
      .cornerRadius(AppTheme.CornerRadius.large)
    }
  }
  
  // MARK: - Transactions List
  private var transactionsList: some View {
    VStack(spacing: 0) {
      // Summary Card
      summaryCard
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)

      // Filter Bar & Type Tabs
      HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
        filterBar
        transactionTypeTabs
      }
      .padding(.horizontal, AppTheme.Spacing.lg)
      .padding(.vertical, AppTheme.Spacing.md)

      if viewModel.filteredTransactions.isEmpty {
        emptyState
      } else {
        // Transaction List
        List {
          ForEach(viewModel.groupedTransactions, id: \.0) { date, transactions in
            Section {
              ForEach(transactions, id: \.id) { transaction in
                TransactionCard(transaction: transaction)
                  .listRowInsets(EdgeInsets(top: AppTheme.Spacing.xs, leading: AppTheme.Spacing.lg, bottom: AppTheme.Spacing.xs, trailing: AppTheme.Spacing.lg))
                  .listRowBackground(Color.clear)
                  .listRowSeparator(.hidden)
                  .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                      Task {
                        await viewModel.deleteTransaction(transaction)
                      }
                    } label: {
                      Label("Delete", systemImage: "trash")
                    }
                  }
              }
            } header: {
              sectionHeader(
                date: date,
                income: transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount },
                expenses: transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
              )
            }
          }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
      }
    }
  }
  
  private func sectionHeader(date: String, income: Int, expenses: Int) -> some View {
    VStack(spacing: AppTheme.Spacing.xs) {
      HStack {
        Text(date.formatDateString("EEEE, d MMMM"))
          .font(AppTheme.Typography.bodyBold)
          .foregroundColor(AppTheme.Colors.primaryText)

        Spacer()
      }

      if income > 0 || expenses > 0 {
        HStack(spacing: AppTheme.Spacing.md) {
          if income > 0 {
            HStack(spacing: AppTheme.Spacing.xs) {
              Image(systemName: "arrow.up")
                .font(.system(size: 10))
              Text(income.toCurrency())
                .font(AppTheme.Typography.caption)
            }
            .foregroundColor(AppTheme.Colors.profit)
          }

          if expenses > 0 {
            HStack(spacing: AppTheme.Spacing.xs) {
              Image(systemName: "arrow.down")
                .font(.system(size: 10))
              Text(expenses.toCurrency())
                .font(AppTheme.Typography.caption)
            }
            .foregroundColor(AppTheme.Colors.loss)
          }

          Spacer()
        }
      }
    }
    .padding(.vertical, AppTheme.Spacing.sm)
    .padding(.horizontal, AppTheme.Spacing.md)
    .background(AppTheme.Colors.background)
  }
  
  // MARK: - Empty State
  private var emptyState: some View {
    VStack(spacing: AppTheme.Spacing.lg) {
      Image(systemName: "tray")
        .font(.system(size: 60))
        .foregroundColor(AppTheme.Colors.tertiaryText)
      
      VStack(spacing: AppTheme.Spacing.xs) {
        Text("No Transactions Found")
          .font(AppTheme.Typography.title3)
          .foregroundColor(AppTheme.Colors.primaryText)
        
        Text("Try adjusting your filters or search terms")
          .font(AppTheme.Typography.caption)
          .foregroundColor(AppTheme.Colors.tertiaryText)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(AppTheme.Spacing.xl)
  }
}

struct CustomRowView: View {
    var text: String
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(text)
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Preview
//#Preview("Light Mode") {
//  TransactionView()
//    .preferredColorScheme(.light)
//}
//
//#Preview("Dark Mode") {
//  TransactionView()
//    .preferredColorScheme(.dark)
//}
