import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class InvestmentsViewModel {
    @ObservationIgnored
    @Dependency(\.investmentService) var investmentService

    // MARK: - State
    var investments: [InvestmentModel] = []
    var isLoading = false
    var errorMessage: String?
    var selectedType: InvestmentType?
    var searchText = ""
    var investmentStateView: ViewState<[InvestmentModel]> = .idle

    // MARK: - Computed Properties
    var filteredInvestments: [InvestmentModel] {
        var result = investments

        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { investment in
                investment.name.localizedCaseInsensitiveContains(searchText) ||
                investment.notes?.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        return result
    }

    var investmentsByType: [InvestmentType: [InvestmentModel]] {
        Dictionary(grouping: filteredInvestments, by: { $0.type })
    }

    var totalInvestmentValue: Int {
        filteredInvestments.reduce(0) { $0 + $1.currentValue }
    }

    var totalInitialAmount: Int {
        filteredInvestments.reduce(0) { $0 + $1.initialAmount }
    }

    var totalProfit: Int {
        totalInvestmentValue - totalInitialAmount
    }

    var totalProfitPercentage: Double {
        guard totalInitialAmount > 0 else { return 0 }
        return (Double(totalProfit) / Double(totalInitialAmount)) * 100
    }

    var totalInvestments: Int {
        filteredInvestments.count
    }

    var availableTypes: [InvestmentType] {
        let uniqueTypes = Set(investments.map { $0.type })
        return InvestmentType.allCases.filter { uniqueTypes.contains($0) }
    }

    var typeValues: [InvestmentType: Int] {
        Dictionary(grouping: investments, by: { $0.type })
            .mapValues { investments in
                investments.reduce(0) { $0 + $1.currentValue }
            }
    }

    var typeProfits: [InvestmentType: Int] {
        Dictionary(grouping: investments, by: { $0.type })
            .mapValues { investments in
                investments.reduce(0) { $0 + $1.profit }
            }
    }

    var profitableInvestments: [InvestmentModel] {
        investments.filter { $0.isProfit }
    }

    var losingInvestments: [InvestmentModel] {
        investments.filter { $0.isLoss }
    }

    var maturedInvestments: [InvestmentModel] {
        investments.filter { $0.isMatured }
    }

    var activeInvestments: [InvestmentModel] {
        investments.filter { !$0.isMatured }
    }

    // MARK: - Actions
    func loadInvestments() async {
        investmentStateView = .loading
        do {
            let investments = try await investmentService.fetchAll()
            self.investments = investments
            investmentStateView = investments.isEmpty ? .empty : .success(investments)
        } catch {
            let errorMessage = "Failed to load investments: \(error.localizedDescription)"
            self.errorMessage = errorMessage
            investmentStateView = .error(error)
        }
    }

    func refreshInvestments() async {
        await loadInvestments()
    }

    func selectType(_ type: InvestmentType?) {
        selectedType = type
    }

    func clearFilters() {
        selectedType = nil
        searchText = ""
    }

    func deleteInvestment(_ investment: InvestmentModel) async {
        do {
            try await investmentService.delete(investment.id)
            investments.removeAll { $0.id == investment.id }
        } catch {
            errorMessage = "Failed to delete investment: \(error.localizedDescription)"
        }
    }

    func updateInvestmentValue(_ investment: InvestmentModel, newValue: Int) async {
        do {
            try await investmentService.updateCurrentValue(investment.id, newValue)
            if let index = investments.firstIndex(where: { $0.id == investment.id }) {
                var updated = investment
                investments[index] = InvestmentModel(
                    id: updated.id,
                    userId: updated.userId,
                    name: updated.name,
                    type: updated.type,
                    accountId: updated.accountId,
                    accountName: updated.accountName,
                    initialAmount: updated.initialAmount,
                    currentValue: newValue,
                    purchaseDate: updated.purchaseDate,
                    maturityDate: updated.maturityDate,
                    interestRate: updated.interestRate,
                    units: updated.units,
                    pricePerUnit: updated.pricePerUnit,
                    notes: updated.notes,
                    createdAt: updated.createdAt,
                    updatedAt: Date()
                )
            }
        } catch {
            errorMessage = "Failed to update investment value: \(error.localizedDescription)"
        }
    }

    func getInvestment(by id: String) -> InvestmentModel? {
        investments.first { $0.id == id }
    }

    func getTopPerformers(limit: Int = 5) -> [InvestmentModel] {
        Array(investments.sorted { $0.profitPercentage > $1.profitPercentage }.prefix(limit))
    }

    func getWorstPerformers(limit: Int = 5) -> [InvestmentModel] {
        Array(investments.sorted { $0.profitPercentage < $1.profitPercentage }.prefix(limit))
    }
}
