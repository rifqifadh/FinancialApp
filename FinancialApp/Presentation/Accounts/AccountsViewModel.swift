import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class AccountsViewModel {
  @ObservationIgnored
  @Dependency(\.accountService) var accountService
  
  // MARK: - State
  var accounts: [AccountModel] = []
  var isLoading = false
  var errorMessage: String?
  var selectedCategory: AccountCategory?
  var searchText = ""
  var accountStateView: ViewState<[AccountModel]> = .idle
  
  // MARK: - Computed Properties
  var filteredAccounts: [AccountModel] {
    var result = accounts
    
    // Filter by category
    if let category = selectedCategory {
      result = result.filter { $0.category == category }
    }
    
    // Filter by search text
    if !searchText.isEmpty {
      result = result.filter { account in
        account.name.localizedCaseInsensitiveContains(searchText) ||
        account.accountNumber?.contains(searchText) == true
      }
    }
    
    return result
  }
  
  var accountsByCategory: [AccountCategory: [AccountModel]] {
    Dictionary(grouping: filteredAccounts, by: { $0.category })
  }
  
  var totalBalance: Double {
    filteredAccounts.reduce(0) { $0 + $1.finalBalance }
  }
  
  var totalAccounts: Int {
    filteredAccounts.count
  }
  
  var availableCategories: [AccountCategory] {
    let uniqueCategories = Set(accounts.map { $0.category })
    return AccountCategory.allCases.filter { uniqueCategories.contains($0) }
  }
  
  var categoryBalances: [AccountCategory: Double] {
    Dictionary(grouping: accounts, by: { $0.category })
      .mapValues { accounts in
        accounts.reduce(0) { $0 + $1.finalBalance }
      }
  }
  
  // MARK: - Actions
  func loadAccounts() async {
    accountStateView = .loading
    do {
      let accounts = try await accountService.fetchAll()
      self.accounts = accounts
      accountStateView = .success(accounts)
    } catch {
      let errorMessage = "Failed to load accounts: \(error.localizedDescription)"
      self.errorMessage = errorMessage
      accountStateView = .error(error)
    }
  }
  
  func refreshAccounts() async {
    await loadAccounts()
  }
  
  func selectCategory(_ category: AccountCategory?) {
    selectedCategory = category
  }
  
  func clearFilters() {
    selectedCategory = nil
    searchText = ""
  }
  
  func deleteAccount(_ account: AccountModel) async {
    do {
      try await accountService.delete(account.id)
      accounts.removeAll { $0.id == account.id }
    } catch {
      errorMessage = "Failed to delete account: \(error.localizedDescription)"
    }
  }
  
  func getAccount(by id: String) -> AccountModel? {
    accounts.first { $0.id == id }
  }
}
