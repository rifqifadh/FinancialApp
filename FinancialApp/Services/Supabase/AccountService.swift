import Dependencies
import Foundation
import Supabase

struct AccountService: Sendable {
    var fetchAll: @Sendable () async throws -> [AccountModel]
    var fetchById: @Sendable (_ id: String) async throws -> AccountModel?
    var create: @Sendable (_ account: CreateAccountParams) async throws -> AccountModel
    var update: @Sendable (_ id: String, _ params: UpdateAccountParams) async throws -> AccountModel
    var delete: @Sendable (_ id: String) async throws -> Void
}

// MARK: - Request Parameters
struct CreateAccountParams: Codable, Sendable {
    let name: String
    let category: String
    let currency: String
    let accountNumber: String?
    let initialBalance: Int

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case currency
        case accountNumber = "account_number"
        case initialBalance = "initial_balance"
    }
}

struct UpdateAccountParams: Codable, Sendable {
    let name: String?
    let category: String?
    let accountNumber: String?

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case accountNumber = "account_number"
    }
}

// MARK: - Dependency Key
extension AccountService: DependencyKey {
    static let liveValue = AccountService(
        fetchAll: {
            let accounts: [AccountModel] = try await SupabaseManager.shared.client
                .from("accounts")
                .select()
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
            let account: AccountModel = try await SupabaseManager.shared.client
                .from("accounts")
                .insert(params)
                .select()
                .single()
                .execute()
                .value
            return account
        },
        update: { id, params in
            let account: AccountModel = try await SupabaseManager.shared.client
                .from("accounts")
                .update(params)
                .eq("id", value: id)
                .select()
                .single()
                .execute()
                .value
            return account
        },
        delete: { id in
            try await SupabaseManager.shared.client
                .from("accounts")
                .delete()
                .eq("id", value: id)
                .execute()
        }
    )

    static let testValue = AccountService(
        fetchAll: {
            AccountModel.mockAccounts
        },
        fetchById: { id in
            AccountModel.mockAccounts.first { $0.id == id }
        },
        create: { _ in
            AccountModel.mockBank
        },
        update: { _, _ in
            AccountModel.mockBank
        },
        delete: { _ in }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    var accountService: AccountService {
        get { self[AccountService.self] }
        set { self[AccountService.self] = newValue }
    }
}
