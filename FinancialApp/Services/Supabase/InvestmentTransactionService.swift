import Dependencies
import Foundation
import Supabase

struct InvestmentTransactionService: Sendable {
    var fetchAll: @Sendable (_ investmentId: String) async throws -> [InvestmentTransactionModel]
    var fetchById: @Sendable (_ id: String) async throws -> InvestmentTransactionModel?
    var create: @Sendable (_ params: CreateInvestmentTransactionParams) async throws -> Void
    var update: @Sendable (_ id: String, _ params: UpdateInvestmentTransactionParams) async throws -> Void
    var delete: @Sendable (_ id: String) async throws -> Void
}

// MARK: - Request Parameters
struct CreateInvestmentTransactionParams: Codable, Sendable {
    let investmentId: String
    let type: String
    let units: Double
    let pricePerUnit: Int
    let totalAmount: Int
    let transactionDate: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case investmentId = "investment_id"
        case type
        case units
        case pricePerUnit = "price_per_unit"
        case totalAmount = "total_amount"
        case transactionDate = "transaction_date"
        case notes
    }
}

struct UpdateInvestmentTransactionParams: Codable, Sendable {
    let type: String?
    let units: Double?
    let pricePerUnit: Int?
    let totalAmount: Int?
    let transactionDate: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case type
        case units
        case pricePerUnit = "price_per_unit"
        case totalAmount = "total_amount"
        case transactionDate = "transaction_date"
        case notes
    }
}

// MARK: - Dependency Key
extension InvestmentTransactionService: DependencyKey {
    static let liveValue = InvestmentTransactionService(
        fetchAll: { investmentId in
//            let transactions: [InvestmentTransactionModel] = try await SupabaseManager.shared.client
//                .from("investment_transactions")
//                .select()
//                .eq("investment_id", value: investmentId)
//                .order("transaction_date", ascending: false)
//                .execute()
//                .value
//            return transactions
          return InvestmentTransactionModel.mockTransactions.filter { $0.investmentId == investmentId }
        },
        fetchById: { id in
//            let transactions: [InvestmentTransactionModel] = try await SupabaseManager.shared.client
//                .from("investment_transactions")
//                .select()
//                .eq("id", value: id)
//                .execute()
//                .value
//            return transactions.first
          return InvestmentTransactionModel.mockTransactions.first { $0.id == id }
        },
        create: { params in
            try await SupabaseManager.shared.client
                .rpc("insert_investment_transaction", params: params)
                .execute()
        },
        update: { id, params in
            try await SupabaseManager.shared.client
                .from("investment_transactions")
                .update(params)
                .eq("id", value: id)
                .execute()
        },
        delete: { id in
            try await SupabaseManager.shared.client
                .from("investment_transactions")
                .delete()
                .eq("id", value: id)
                .execute()
        }
    )

    static let testValue = InvestmentTransactionService(
        fetchAll: { investmentId in
            InvestmentTransactionModel.mockTransactions.filter { $0.investmentId == investmentId }
        },
        fetchById: { id in
            InvestmentTransactionModel.mockTransactions.first { $0.id == id }
        },
        create: { _ in },
        update: { _, _ in },
        delete: { _ in }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    var investmentTransactionService: InvestmentTransactionService {
        get { self[InvestmentTransactionService.self] }
        set { self[InvestmentTransactionService.self] = newValue }
    }
}
