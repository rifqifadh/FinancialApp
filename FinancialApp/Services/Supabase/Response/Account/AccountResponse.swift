import Foundation

struct AccountResponse: Codable, Sendable {
    let accounts: [AccountModel]
    let totalBalance: Int?

    enum CodingKeys: String, CodingKey {
        case accounts
        case totalBalance = "total_balance"
    }

    init(from decoder: Decoder) throws {
        // Try to decode as array first (for direct account list responses)
        if let accountsArray = try? decoder.singleValueContainer().decode([AccountModel].self) {
            self.accounts = accountsArray
            self.totalBalance = accountsArray.reduce(0) { $0 + $1.finalBalance }
        } else {
            // Otherwise decode as object with accounts property
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accounts = try container.decode([AccountModel].self, forKey: .accounts)
            totalBalance = try container.decodeIfPresent(Int.self, forKey: .totalBalance)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encodeIfPresent(totalBalance, forKey: .totalBalance)
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

    init(accounts: [AccountModel], totalBalance: Int?) {
        self.accounts = accounts
        self.totalBalance = totalBalance
    }
}
