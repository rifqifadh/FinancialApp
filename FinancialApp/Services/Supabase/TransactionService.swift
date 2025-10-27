//
//  TransactionService.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Dependencies
import Supabase
import Foundation

struct TransactionService: Sendable {
  var deleteById: @Sendable (_ id: UUID) async throws -> Void
  var fetchAll: @Sendable (_ params: TransactionParams) async throws -> TransactionResponse
  var fetchAllById: @Sendable (_ params: TransactionParams) async throws -> TransactionResponse
}

extension TransactionService: DependencyKey {
  static let liveValue = TransactionService(
    deleteById: { id in
      do {
        try await SupabaseManager.shared.client
          .from("transactions")
          .delete()
          .eq("id", value: id.uuidString)
          .execute()
      } catch {
        throw error
      }
    },
    fetchAll: { params in
      do {
        let result: TransactionResponse = try await SupabaseManager.shared.client.rpc("get_transactions", params: ["params": params]).execute().value
        return result
      } catch {
        throw error
      }
    },
    fetchAllById: { params in
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
