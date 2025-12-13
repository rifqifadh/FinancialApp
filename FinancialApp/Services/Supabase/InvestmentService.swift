import Dependencies
import Foundation
import Supabase

struct InvestmentService: Sendable {
  var fetchAll: @Sendable () async throws -> [InvestmentResponse]
  var fetchById: @Sendable (_ id: String) async throws -> InvestmentResponse?
  var create: @Sendable (_ params: InsertInvestmentParams) async throws -> String
  var update: @Sendable (_ id: String, _ params: UpdateInvestmentParams) async throws -> Void
  var delete: @Sendable (_ id: String) async throws -> Void
  var updateCurrentValue: @Sendable (_ id: String, _ currentValue: Double) async throws -> Void
}

// MARK: - Dependency Key
extension InvestmentService: DependencyKey {
  static let liveValue = InvestmentService(
    fetchAll: {
      // Use the custom RPC function to get investments with account names
      let investments: [InvestmentResponse] = try await SupabaseManager.shared.client
        .rpc("get_user_investments")
        .execute()
        .value
      return investments
    },
    fetchById: { id in
      let investments: [InvestmentResponse] = try await SupabaseManager.shared.client
        .from("investments")
        .select()
        .eq("id", value: id)
        .execute()
        .value
      return investments.first
    },
    create: { params in
      // Wrap params in a "params" key as expected by the JSONB function
      let wrappedParams = ["params": params]

      let investmentId: String = try await SupabaseManager.shared.client
        .rpc("insert_investment", params: wrappedParams)
        .execute()
        .value
      return investmentId
    },
    update: { id, params in
      struct UpdateParams: Codable {
        let name: String?
        let type: String?
        let accountId: String?
        let currentValue: String?
        let maturityDate: String?
        let interestRate: Double?
        let units: Double?
        let pricePerUnit: String?
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
      
      let updateData = UpdateParams(
        name: params.name,
        type: params.type,
        accountId: params.accountId,
        currentValue: params.currentValue.map { String($0) },
        maturityDate: params.maturityDate,
        interestRate: params.interestRate,
        units: params.units,
        pricePerUnit: params.pricePerUnit.map { String($0) },
        notes: params.notes
      )
      
      try await SupabaseManager.shared.client
        .from("investments")
        .update(updateData)
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
  
  static let previewValue = InvestmentService.mockPreviewValue
  
  static let testValue = InvestmentService(
    fetchAll: {
      InvestmentResponse.mockInvestments
    },
    fetchById: { id in
      InvestmentResponse.mockInvestments.first { $0.id == id }
    },
    create: { _ in "test-id" },
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
