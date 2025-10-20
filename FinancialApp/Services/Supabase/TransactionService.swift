//
//  TransactionService.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Dependencies
import Supabase

struct TransactionService: Sendable {
//  var deleteById: @Sendable (_ id: String) async throws -> Void
  var fetchAll: @Sendable () async throws -> TransactionResponse
}

extension TransactionService: DependencyKey {
  static let liveValue = TransactionService(
    fetchAll: {
      do {
        let result: TransactionResponse = try await SupabaseManager.shared.client.rpc("get_transactions").execute().value
        return result
      } catch {
        throw error
      }
    }
  )
}

extension DependencyValues {
  var transactionService: TransactionService {
    get { self[TransactionService.self] }
    set { self[TransactionService.self] = newValue }
  }
}
