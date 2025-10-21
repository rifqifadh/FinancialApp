import Foundation

struct AccountResponse: Codable, Sendable {
    let accounts: [AccountModel]
    let totalBalance: Int?

    enum CodingKeys: String, CodingKey {
        case accounts
        case totalBalance = "total_balance"
    }
    // Computed properties
    var accountsByCategory: [AccountCategory: [AccountModel]] {
        Dictionary(grouping: accounts, by: { $0.category })
    }

    var totalAccounts: Int {
        accounts.count
    }

    var calculatedTotalBalance: Int {
        accounts.reduce(0) { $0 + $1.finalBalance }
    }
}

// MARK: - Mock Data
extension AccountResponse {
  static let mock = AccountResponse(
    accounts: AccountModel.mockAccounts,
    totalBalance: AccountModel.mockAccounts.reduce(0) { $0 + $1.finalBalance }
  )
}
