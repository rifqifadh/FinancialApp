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
    var investment: InvestmentModel?
    var transactions: [InvestmentTransactionModel] = []
    var isLoading = false
    var errorMessage: String?
    var transactionsStateView: ViewState<[InvestmentTransactionModel]> = .idle

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

    var totalBuyAmount: Int {
        buyTransactions.reduce(0) { $0 + $1.totalAmount }
    }

    var totalSellAmount: Int {
        sellTransactions.reduce(0) { $0 + $1.totalAmount }
    }

    var totalDividends: Int {
        dividendTransactions.reduce(0) { $0 + $1.totalAmount }
    }

    var totalBuyUnits: Double {
        buyTransactions.reduce(0) { $0 + $1.units }
    }

    var totalSellUnits: Double {
        sellTransactions.reduce(0) { $0 + $1.units }
    }

    var currentHoldingUnits: Double {
        totalBuyUnits - totalSellUnits
    }

    var averageBuyPrice: Int {
        guard totalBuyUnits > 0 else { return 0 }
        return Int(Double(totalBuyAmount) / totalBuyUnits)
    }

    var currentPrice: Int {
        guard let investment = investment, currentHoldingUnits > 0 else { return 0 }
        return Int(Double(investment.currentValue) / currentHoldingUnits)
    }

    var unrealizedProfit: Int {
        guard let investment = investment else { return 0 }
        let currentValueOfHoldings = Int(currentHoldingUnits * Double(currentPrice))
        let costBasis = Int(currentHoldingUnits * Double(averageBuyPrice))
        return currentValueOfHoldings - costBasis
    }

    var realizedProfit: Int {
        totalSellAmount - Int(totalSellUnits * Double(averageBuyPrice))
    }

    var totalProfit: Int {
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

    func recalculateInvestmentValue(_ investment: InvestmentModel) async {
        // For stocks, calculate current value based on holdings
        if investment.type == .stocks || investment.type == .reksaDanaSaham {
            let newValue = Int(currentHoldingUnits * Double(currentPrice))
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
}
