//
//  TransactionsViewModel.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Observation
import Foundation
import Dependencies
import SwiftUI

@MainActor
@Observable
final class TransactionsViewModel {
  @ObservationIgnored
  @Dependency(\.transactionService) var transactionService
  
  // MARK: - Properties
  var transactions: [TransactionModel] = []
  var selectedMonth: Date = Date()
  var selectedType: TransactionType? = nil
  var selectedCategoryId: Int? = nil
  var searchText: String = ""
  var showFilterSheet: Bool = false
  var sortOrder: SortOrder = .dateDescending

  // MARK: - Sort Order
  enum SortOrder {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending
  }

  // MARK: - Computed Properties
  var filteredTransactions: [TransactionModel] {
    var result = transactions.filter { transaction in
      // Filter by month
      let monthMatches = Calendar.current.isDate(
        transaction.spentAt.toDate(),
        equalTo: selectedMonth,
        toGranularity: .month
      )

      // Filter by type
      let typeMatches = selectedType == nil || transaction.type == selectedType

      // Filter by category
      let categoryMatches = selectedCategoryId == nil || transaction.categoryId == selectedCategoryId

      // Filter by search text
      let searchMatches = searchText.isEmpty ||
      transaction.description.localizedCaseInsensitiveContains(searchText) ||
      transaction.accountName.localizedCaseInsensitiveContains(searchText) ||
      (transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)

      return monthMatches && typeMatches && categoryMatches && searchMatches
    }

    // Apply sorting
    switch sortOrder {
    case .dateDescending:
      result.sort { $0.spentAt.toDate() > $1.spentAt.toDate() }
    case .dateAscending:
      result.sort { $0.spentAt.toDate() < $1.spentAt.toDate() }
    case .amountDescending:
      result.sort { $0.amount > $1.amount }
    case .amountAscending:
      result.sort { $0.amount < $1.amount }
    }

    return result
  }

  var totalIncome: Int {
    filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
  }

  var totalExpenses: Int {
    filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
  }

  var netAmount: Int {
    totalIncome - totalExpenses
  }

  var groupedTransactions: [(String, [TransactionModel])] {
    let grouped = Dictionary(grouping: filteredTransactions) { transaction in
      transaction.spentAt.formatDate("yyyy-MM-dd")
    }
    return grouped.sorted { $0.key > $1.key }
  }

  var availableCategories: [TransactionCategory] {
    Array(Set(transactions.compactMap { $0.category }))
      .sorted { $0.name < $1.name }
  }

  // MARK: - Methods
  func selectMonth(_ monthOffset: Int) {
    
    let selectedMonth = Calendar.current.date(
      byAdding: .month,
      value: monthOffset,
      to: Date()
    ) ?? Date()
    self.selectedMonth = selectedMonth
    Task {
      await loadTransactions(month: selectedMonth)
    }
  }

  func selectType(_ type: TransactionType?) {
    selectedType = type
  }

  func setSortOrder(_ order: SortOrder) {
    sortOrder = order
  }

  func toggleFilterSheet() {
    showFilterSheet.toggle()
  }

  func resetFilters() {
    selectedType = nil
    selectedCategoryId = nil
    selectedMonth = Date()
    searchText = ""
  }

  // MARK: - Data Loading
  func loadTransactions(month: Date? = nil) async {
    do {
      let result = try await transactionService.fetchAll(.init(month: selectedMonth))
      transactions = result.data
    } catch {
      print(error.localizedDescription)
    }
  }

  func refreshTransactions() async {
    // TODO: Implement actual refresh logic
    // This is where you would call your Supabase service
//    try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
    await loadTransactions()
  }
}
