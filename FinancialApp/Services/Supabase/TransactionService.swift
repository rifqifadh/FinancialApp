//
//  TransactionService.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Dependencies
import Supabase
import Foundation

struct TransactionParams: Encodable, Sendable {
  let month: Date
}

struct TransactionService: Sendable {
//  var deleteById: @Sendable (_ id: String) async throws -> Void
  var fetchAll: @Sendable (_ params: TransactionParams) async throws -> TransactionResponse
}

extension TransactionService: DependencyKey {
  static let liveValue = TransactionService(
    fetchAll: { params in
      do {
        let result: TransactionResponse = try await SupabaseManager.shared.client.rpc("get_transactions", params: ["params": params]).execute().value
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
