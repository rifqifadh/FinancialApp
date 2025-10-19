//
//  ExpenseService.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import Dependencies
import Supabase

struct ExpenseService: Sendable {
  var deleteById: @Sendable (_ id: String) async throws -> Void
  var fetchAll: @Sendable (_ params: ExpensesFilterParams) async throws -> ExpensesSummaryResponse
}

extension ExpenseService: DependencyKey {
  static let liveValue = ExpenseService(
    deleteById: { id in
      do {
        try await SupabaseManager.shared.client.from("transactions").delete().eq("id", value: id).execute()
      } catch {
        throw error
      }
    },
    fetchAll: { params in
      
      do {
        let data: ExpensesSummaryResponse? = try await SupabaseManager.shared.client.rpc("get_monthly_expenses_with_total", params: params).execute().value
        return data ?? ExpensesSummaryResponse(total: 0, records: [])
      } catch {
        throw error
      }
    }
  )
}

extension DependencyValues {
  var expenseService: ExpenseService {
    get { self[ExpenseService.self] }
    set { self[ExpenseService.self] = newValue }
  }
}
