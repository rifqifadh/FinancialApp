import Dependencies
import Foundation
import Supabase

struct InvestmentService: Sendable {
    var fetchAll: @Sendable () async throws -> [InvestmentModel]
    var fetchById: @Sendable (_ id: String) async throws -> InvestmentModel?
    var create: @Sendable (_ params: CreateInvestmentParams) async throws -> Void
    var update: @Sendable (_ id: String, _ params: UpdateInvestmentParams) async throws -> Void
    var delete: @Sendable (_ id: String) async throws -> Void
    var updateCurrentValue: @Sendable (_ id: String, _ currentValue: Int) async throws -> Void
}

// MARK: - Request Parameters
struct CreateInvestmentParams: Codable, Sendable {
    let name: String
    let type: String
    let accountId: String?
    let initialAmount: Int
    let currentValue: Int
    let purchaseDate: String
    let maturityDate: String?
    let interestRate: Double?
    let units: Double?
    let pricePerUnit: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case accountId = "account_id"
        case initialAmount = "initial_amount"
        case currentValue = "current_value"
        case purchaseDate = "purchase_date"
        case maturityDate = "maturity_date"
        case interestRate = "interest_rate"
        case units
        case pricePerUnit = "price_per_unit"
        case notes
    }
}

struct UpdateInvestmentParams: Codable, Sendable {
    let name: String?
    let type: String?
    let accountId: String?
    let currentValue: Int?
    let maturityDate: String?
    let interestRate: Double?
    let units: Double?
    let pricePerUnit: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case accountId = "account_id"
        case currentValue = "current_value"
        case maturityDate = "maturity_date"
        case interestRate = "interest_rate"
        case units
        case pricePerUnit = "price_per_unit"
        case notes
    }
}

// MARK: - Dependency Key
extension InvestmentService: DependencyKey {
    static let liveValue = InvestmentService(
        fetchAll: {
            let userId = try await SupabaseManager.shared.client.auth.user().id.uuidString
//            let investments: [InvestmentModel] = try await SupabaseManager.shared.client
//                .from("investments")
//                .select()
//                .eq("user_id", value: userId)
//                .order("purchase_date", ascending: false)
//                .execute()
//                .value
          return InvestmentModel.mockInvestments
        },
        fetchById: { id in
//            let investments: [InvestmentModel] = try await SupabaseManager.shared.client
//                .from("investments")
//                .select()
//                .eq("id", value: id)
//                .execute()
//                .value
          return InvestmentModel.mockInvestments.first { $0.id == id }
        },
        create: { params in
            try await SupabaseManager.shared.client
                .rpc("insert_investment", params: params)
                .execute()
        },
        update: { id, params in
            var updateParams = params
            try await SupabaseManager.shared.client
                .from("investments")
                .update(updateParams)
                .eq("id", value: id)
                .execute()
        },
        delete: { id in
            try await SupabaseManager.shared.client
                .from("investments")
                .delete()
                .eq("id", value: id)
                .execute()
        },
        updateCurrentValue: { id, currentValue in
            struct CurrentValueUpdate: Codable {
                let currentValue: String

                enum CodingKeys: String, CodingKey {
                    case currentValue = "current_value"
                }
            }

            try await SupabaseManager.shared.client
                .from("investments")
                .update(CurrentValueUpdate(currentValue: String(currentValue)))
                .eq("id", value: id)
                .execute()
        }
    )

    static let testValue = InvestmentService(
        fetchAll: {
            InvestmentModel.mockInvestments
        },
        fetchById: { id in
            InvestmentModel.mockInvestments.first { $0.id == id }
        },
        create: { _ in },
        update: { _, _ in },
        delete: { _ in },
        updateCurrentValue: { _, _ in }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    var investmentService: InvestmentService {
        get { self[InvestmentService.self] }
        set { self[InvestmentService.self] = newValue }
    }
}
