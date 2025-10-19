//
//  TEMPLATE: Service
//  
//  Replace [Feature] with your feature name (e.g., Expense, Asset)
//  Replace [Item] with your model name (e.g., Expense, Asset)
//  Replace [table_name] with your Supabase table name
//

import Foundation
import Supabase


import Dependencies
import Supabase

struct [Feature]Service {
  var delete: @Sendable (_ id: String) async throws -> Void
  var fetchAll: @Sendable (_ params: ExpensesFilterParams) async throws -> ExpensesSummaryResponse
  var fetchById: @Sendable (_ id: UUID) async throws -> [Item]
}

extension [Feature]Service: DependencyKey {
  static let liveValue = [Feature]Service(
      delete: { id in
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
      },
    fetchById: { id in
        do {
            let items: [[Item]] = try await SupabaseManager.shared.client
             .from("[table_name]")
             .select()
             .eq("id", value: id)
             .limit(1)
             .execute()
             .value
            
            guard let item = items.first else {
                throw FinanceAppError.invalidData
            }
            
          return item
        } catch {
            throw error
        }
    }
  )
}
