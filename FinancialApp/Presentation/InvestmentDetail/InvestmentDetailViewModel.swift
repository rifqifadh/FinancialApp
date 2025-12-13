import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class InvestmentDetailViewModel {
  @ObservationIgnored
  @Dependency(\.investmentService) var investmentService
  
  @ObservationIgnored
  @Dependency(\.investmentTransactionService) var transactionService
  
  // MARK: - State
  var investment: InvestmentResponse?
  var transactions: [InvestmentTransactionModel] = []
  var isLoading = false
  var errorMessage: String?
  var transactionsStateView: ViewState<[InvestmentTransactionModel]> = .idle
  
  // Filter & Sort State
  var selectedFilter: TransactionFilter = .all
  var selectedSort: TransactionSortOption = .dateNewest
  var searchText: String = ""
  var transactionToDelete: InvestmentTransactionModel?
  var showingDeleteConfirmation = false
  
  // MARK: - Computed Properties
  var filteredAndSortedTransactions: [InvestmentTransactionModel] {
    var result = transactions
    
    // Apply filter
    result = result.filter { selectedFilter.matches($0) }
    
    // Apply search
    if !searchText.isEmpty {
      result = result.filter { transaction in
        let searchLower = searchText.lowercased()
        return transaction.type.rawValue.lowercased().contains(searchLower) ||
        (transaction.notes?.lowercased().contains(searchLower) ?? false)
      }
    }
    
    // Apply sort
    switch selectedSort {
    case .dateNewest:
      result.sort { $0.transactionDate > $1.transactionDate }
    case .dateOldest:
      result.sort { $0.transactionDate < $1.transactionDate }
    case .amountHighest:
      result.sort { $0.totalAmount > $1.totalAmount }
    case .amountLowest:
      result.sort { $0.totalAmount < $1.totalAmount }
    }
    
    return result
  }
  
  // MARK: - Computed Properties
  var buyTransactions: [InvestmentTransactionModel] {
    transactions.filter { $0.type == .buy }
  }
  
  var sellTransactions: [InvestmentTransactionModel] {
    transactions.filter { $0.type == .sell }
  }
  
  var dividendTransactions: [InvestmentTransactionModel] {
    transactions.filter { $0.type == .dividend }
  }
  
  var totalBuyAmount: Double {
    buyTransactions.reduce(0) { $0 + $1.totalAmount }
  }
  
  var totalSellAmount: Double {
    sellTransactions.reduce(0) { $0 + $1.totalAmount }
  }
  
  var totalDividends: Double {
    dividendTransactions.reduce(0) { $0 + $1.totalAmount }
  }
  
  var totalBuyUnits: Int {
    buyTransactions.reduce(0) { $0 + $1.units }
  }
  
  var totalSellUnits: Int {
    sellTransactions.reduce(0) { $0 + $1.units }
  }
  
  var currentHoldingUnits: Int {
    totalBuyUnits - totalSellUnits
  }

  // Lot computed properties (units / 100)
  var totalBuyLot: Int {
    totalBuyUnits / 100
  }

  var totalSellLot: Int {
    totalSellUnits / 100
  }

  var currentHoldingLot: Int {
    currentHoldingUnits / 100
  }

  var averageBuyPrice: Double {
    guard totalBuyUnits > 0 else { return 0 }
    return totalBuyAmount / Double(totalBuyUnits)
  }

  var currentPrice: Double {
    // Use pricePerUnit from investment for the most up-to-date price
    guard let investment = investment else { return 0 }
    if let pricePerUnit = investment.pricePerUnit {
      return Double(pricePerUnit)
    }
    // Fallback to calculating from current value and units
    guard currentHoldingUnits > 0 else { return 0 }
    return Double(investment.currentValue) / Double(currentHoldingUnits)
  }
  
  var unrealizedProfit: Double {
    guard investment != nil else { return 0 }
    let currentValueOfHoldings = Double(currentHoldingUnits) * currentPrice
    let costBasis = Double(currentHoldingUnits) * averageBuyPrice
    return currentValueOfHoldings - costBasis
  }
  
  var realizedProfit: Double {
    totalSellAmount - Double(totalSellUnits) * Double(averageBuyPrice)
  }
  
  var totalProfit: Double {
    unrealizedProfit + realizedProfit + totalDividends
  }
  
  var totalReturn: Double {
    guard totalBuyAmount > 0 else { return 0 }
    return (Double(totalProfit) / Double(totalBuyAmount)) * 100
  }
  
  // Transaction summary by month
  var transactionsByMonth: [String: [InvestmentTransactionModel]] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    
    return Dictionary(grouping: transactions) { transaction in
      dateFormatter.string(from: transaction.transactionDate)
    }
  }
  
  // MARK: - Actions
  func loadInvestment(id: String) async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      investment = try await investmentService.fetchById(id)
    } catch {
      errorMessage = "Failed to load investment: \(error.localizedDescription)"
    }
  }
  
  func loadTransactions(investmentId: String) async {
    transactionsStateView = .loading
    do {
      let transactions = try await transactionService.fetchAll(investmentId)
      self.transactions = transactions
      transactionsStateView = .success(transactions)
    } catch {
      let errorMessage = "Failed to load transactions: \(error.localizedDescription)"
      self.errorMessage = errorMessage
      transactionsStateView = .error(error)
    }
  }
  
  func refreshAll(investmentId: String) async {
    await loadInvestment(id: investmentId)
    await loadTransactions(investmentId: investmentId)
  }
  
  func deleteTransaction(_ transaction: InvestmentTransactionModel) async {
    do {
      try await transactionService.delete(transaction.id)
      transactions.removeAll { $0.id == transaction.id }
      
      // Recalculate investment current value after deletion
      if let investment = investment {
        await recalculateInvestmentValue(investment)
      }
    } catch {
      errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
    }
  }
  
  func recalculateInvestmentValue(_ investment: InvestmentResponse) async {
    // For stocks, calculate current value based on holdings
    if investment.type == .stocks || investment.type == .reksaDanaSaham {
      let newValue = Double(currentHoldingUnits) * currentPrice
      do {
        try await investmentService.updateCurrentValue(investment.id, newValue)
        self.investment = try await investmentService.fetchById(investment.id)
      } catch {
        errorMessage = "Failed to update investment value: \(error.localizedDescription)"
      }
    }
  }
  
  func getTransaction(by id: String) -> InvestmentTransactionModel? {
    transactions.first { $0.id == id }
  }
  
  func confirmDelete(_ transaction: InvestmentTransactionModel) {
    transactionToDelete = transaction
    showingDeleteConfirmation = true
  }
  
  func cancelDelete() {
    transactionToDelete = nil
    showingDeleteConfirmation = false
  }
  
  func performDelete() async {
    guard let transaction = transactionToDelete else { return }
    showingDeleteConfirmation = false
    await deleteTransaction(transaction)
    transactionToDelete = nil
  }

  func updatePricePerUnit(_ investment: InvestmentResponse, newPrice: Int) async {
    do {
      // Calculate new current value based on holdings and new price
      let newValue: Int
      if let units = investment.units, units > 0 {
        newValue = Int(units * Double(newPrice))
      } else {
        // Fallback to current value if units is not available
        newValue = investment.currentValue
      }

      let params = UpdateInvestmentParams(
        name: nil,
        type: nil,
        accountId: nil,
        currentValue: newValue,
        maturityDate: nil,
        interestRate: nil,
        units: nil,
        pricePerUnit: newPrice,
        notes: nil
      )

      try await investmentService.update(investment.id, params)

      // Reload investment to get updated values
      self.investment = try await investmentService.fetchById(investment.id)
    } catch {
      errorMessage = "Failed to update price: \(error.localizedDescription)"
    }
  }
}
