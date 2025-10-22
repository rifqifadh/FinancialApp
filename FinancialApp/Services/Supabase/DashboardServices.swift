//
//  DashboardServices.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Supabase
import Foundation
import Dependencies

struct DashboardSummary: Codable, Sendable {
  let totalIncome: Double
  let totalExpense: Double
//  let totalAsset: Double
  
  enum CodingKeys: String, CodingKey {
    case totalIncome = "total_income"
    case totalExpense = "total_expense"
  }
}

struct DashboardServices: Sendable {
  var fetchSummary: @Sendable () async throws -> BaseResponse<DashboardSummary>
}

extension DashboardServices: DependencyKey {
  static let liveValue = DashboardServices(
    fetchSummary: {
      do {
        let result: BaseResponse<DashboardSummary> = try await SupabaseManager.shared.client
          .rpc("get_transactions_totals", params: ["params": ["month": Date()]])
          .execute()
          .value
        return result
      } catch {
        throw error
      }
    }
  )
}

extension DependencyValues {
  var dashboardServices: DashboardServices {
    get { self[DashboardServices.self] }
    set { self[DashboardServices.self] = newValue }
  }
}
