import Dependencies
import Foundation
import Supabase

struct AccountServices: Sendable {
  var fetchAll: @Sendable () async throws -> [AccountModel]
  var fetchById: @Sendable (_ id: String) async throws -> AccountModel?
  var create: @Sendable (_ account: CreateAccountParams) async throws -> Void
  var update: @Sendable (_ id: String, _ params: UpdateAccountParams) async throws -> Void
  var delete: @Sendable (_ id: String) async throws -> Void
}

// MARK: - Dependency Key
extension AccountServices: DependencyKey {
  static let liveValue = AccountServices(
    fetchAll: {
      let userId = try await SupabaseManager.shared.client.auth.user().id.uuidString
      let accounts: [AccountModel] = try await SupabaseManager.shared.client
        .from("accounts")
        .select()
        .eq("user_id", value: userId)
        .order("created_at", ascending: false)
        .execute()
        .value
      return accounts
    },
    fetchById: { id in
      let accounts: [AccountModel] = try await SupabaseManager.shared.client
        .from("accounts")
        .select()
        .eq("id", value: id)
        .execute()
        .value
      return accounts.first
    },
    create: { params in
      try await SupabaseManager.shared.client
        .rpc("insert_account", params: params)
        .execute()
    },
    update: { id, params in
      try await SupabaseManager.shared.client
        .rpc("update_account", params: ["params": params])
        .execute()
    },
    delete: { id in
      try await SupabaseManager.shared.client
        .from("accounts")
        .delete()
        .eq("id", value: id)
        .execute()
    }
  )
  
  static let previewValue: AccountServices = AccountServices(
    fetchAll: {
      //      BaseResponse(success: true, message: "OK", data:
      AccountModel.mockAccounts
    },
    fetchById: { id in
      //      BaseResponse(success: true, message: "OK", data:
      AccountModel.mockAccounts.first { $0.id == id }
    },
    create: { _ in },
    update: { _, _ in },
    delete: { _ in }
  )
}

// MARK: - Dependency Values
extension DependencyValues {
  var accountService: AccountServices {
    get { self[AccountServices.self] }
    set { self[AccountServices.self] = newValue }
  }
}
