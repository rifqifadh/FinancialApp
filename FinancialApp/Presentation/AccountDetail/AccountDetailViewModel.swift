import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class AccountDetailViewModel {
  @ObservationIgnored
  @Dependency(\.accountService) var accountService
  
  @ObservationIgnored
  @Dependency(\.transactionService) var transactionService
  
  // MARK: - State
  var account: AccountModel?
  var transactions: [TransactionModel] = []
  var isLoading = false
  var errorMessage: String?
  var transactionsStateView: ViewState<[TransactionModel]> = .idle
  var selectedFilter: TransactionFilter = .all
  var showEditSheet = false
  var id: String
  
  init(id: String) {
    self.id = id
  }
  
  // MARK: - Filter Options
  enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var icon: String {
      switch self {
      case .all:
        return "list.bullet"
      case .income:
        return "arrow.down.circle"
      case .expense:
        return "arrow.up.circle"
      }
    }
  }
  
  // MARK: - Computed Properties
  var filteredTransactions: [TransactionModel] {
    switch selectedFilter {
    case .all:
      return transactions
    case .income:
      return transactions.filter { $0.type.description == "Income" }
    case .expense:
      return transactions.filter { $0.type.description == "Expense" }
    }
  }
  
  var totalIncome: Int {
    transactions.filter { $0.type.description == "Income" }.reduce(0) { $0 + $1.amount }
  }
  
  var totalExpense: Int {
    transactions.filter { $0.type.description == "Expense" }.reduce(0) { $0 + $1.amount }
  }
  
  var netAmount: Int {
    totalIncome - totalExpense
  }
  
  var transactionsByMonth: [String: [TransactionModel]] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    
    return Dictionary(grouping: filteredTransactions) { transaction in
      dateFormatter.string(from: transaction.spentAt.toDate())
    }
  }
  
  var sortedMonths: [String] {
    transactionsByMonth.keys.sorted { month1, month2 in
      let formatter = DateFormatter()
      formatter.dateFormat = "MMMM yyyy"
      guard let date1 = formatter.date(from: month1),
            let date2 = formatter.date(from: month2) else {
        return month1 > month2
      }
      return date1 > date2
    }
  }
  
  // MARK: - Actions
  func loadAccount(id: String) async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      account = try await accountService.fetchById(id)
    } catch {
      errorMessage = "Failed to load account: \(error.localizedDescription)"
    }
  }
  
  func loadTransactions(accountId: String) async {
    transactionsStateView = .loading
    do {
      // Fetch transactions for this specific account
      let allTransactions = try await transactionService.fetchAllById(.init(accountId: id))
      
      transactions = allTransactions.data
      transactionsStateView = .success(transactions)
    } catch {
      let errorMessage = "Failed to load transactions: \(error.localizedDescription)"
      self.errorMessage = errorMessage
      transactionsStateView = .error(error)
    }
  }
  
  func refreshAll(accountId: String) async {
    await loadAccount(id: accountId)
    await loadTransactions(accountId: accountId)
  }
  
  func setFilter(_ filter: TransactionFilter) {
    selectedFilter = filter
  }
  
  func showEditAccount() {
    showEditSheet = true
  }
  
  func updateAccount(updatedAccount: AccountModel) async {
    do {
      try await accountService.update(updatedAccount.id, .init(
        id: updatedAccount.id,
        name: updatedAccount.name,
        category: updatedAccount.category.displayName,
        currency: updatedAccount.currency,
        accountNumber: updatedAccount.name,
        finalBalance: updatedAccount.finalBalance
      ))
      account = updatedAccount
    } catch {
      errorMessage = "Failed to update account: \(error.localizedDescription)"
    }
  }
  
  func deleteTransaction(_ transaction: TransactionModel) async {
    //        do {
    //            try await transactionService.delete(transaction.id)
    //            transactions.removeAll { $0.id == transaction.id }
    //        } catch {
    //            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
    //        }
  }
}
