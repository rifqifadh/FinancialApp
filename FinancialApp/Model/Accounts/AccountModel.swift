import Foundation

struct AccountModel: Identifiable, Codable, Sendable {
    let id: String
    let userId: String
    let name: String
    let category: AccountCategory
    let currency: String
    let createdAt: Date?
    let finalBalance: Int
    let accountNumber: String?
    let initialBalance: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case category
        case currency
        case createdAt = "created_at"
        case finalBalance = "final_balance"
        case accountNumber = "account_number"
        case initialBalance = "initial_balance"
    }

    // Computed properties
    var balance: Int {
        finalBalance
    }

    var balanceChange: Int {
        finalBalance - initialBalance
    }

    var hasPositiveBalance: Bool {
        finalBalance > 0
    }

    var icon: String {
        category.icon
    }
}

// MARK: - Account Category
enum AccountCategory: String, Codable, CaseIterable, Sendable {
    case cash = "Cash"
    case bank = "Bank"
    case eWallet = "E-Wallet"
    case creditCard = "Credit Card"
    case investment = "Investment"
    case other = "Other"

    var icon: String {
        switch self {
        case .cash:
            return "banknote"
        case .bank:
            return "building.columns"
        case .eWallet:
            return "creditcard"
        case .creditCard:
            return "creditcard.circle"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "folder"
        }
    }

    var displayName: String {
        rawValue
    }
}

// MARK: - Mock Data
extension AccountModel {
  static let mockCash = AccountModel(
    id: "1",
    userId: "user1",
    name: "Cash",
    category: .cash,
    currency: "IDR",
    createdAt: Date(),
    finalBalance: 500000,
    accountNumber: nil,
    initialBalance: 0
  )
  
  static let mockBank = AccountModel(
    id: "2",
    userId: "user1",
    name: "Mandiri",
    category: .bank,
    currency: "IDR",
    createdAt: Date(),
    finalBalance: 12712779,
    accountNumber: "1200013276279",
    initialBalance: 0
  )
  
  static let mockEWallet = AccountModel(
    id: "3",
    userId: "user1",
    name: "Gopay",
    category: .eWallet,
    currency: "IDR",
    createdAt: Date(),
    finalBalance: 31587,
    accountNumber: "082124319146",
    initialBalance: 0
  )
  
  static let mockAccounts = [mockCash, mockBank, mockEWallet]
  
  // Custom initializer for manual creation
}
