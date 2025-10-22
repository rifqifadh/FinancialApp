//
//  TransactionResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Foundation

struct TransactionModel: Codable {
  let id: UUID
  let createdAt: String
  let description: String
  let amount: Int
  let categoryId: Int
  let accountId: String
  let accountName: String
  let spentAt: String
  let type: TransactionType
  let category: TransactionCategory?
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case description
    case amount
    case categoryId = "category_id"
    case accountId = "account_id"
    case accountName = "account_name"
    case spentAt = "spent_at"
    case category
    case type
  }
}

enum TransactionType: String, Codable, CustomStringConvertible {
  case expense
  case transfer
  case income
  case split_bill
  
  var description: String {
    switch self {
    case .expense:
      return "Expense"
    case .transfer:
      return "Transfer"
    case .income:
      return "Income"
    case .split_bill:
      return "Split Bill"
    }
  }
}

// MARK: - Mock Data
extension TransactionModel {
  static let mock: TransactionModel = {
    TransactionModel(
      id: UUID(uuidString: "44e01127-913d-4778-9120-41eb8d352015")!,
      createdAt: "2025-08-01T13:15:33.60387+00:00",
      description: "Peralatan badminton",
      amount: 244000,
      categoryId: 13,
      accountId: "b43de564-e6cd-4a76-9f49-25e95c4e2a5f",
      accountName: "Jago Utama (509416230592)",
      spentAt: "2025-08-01T13:15:21.738+00:00",
      type: .expense,
      category: TransactionCategory(
        id: 13,
        iconName: "bag.fill",
        name: "Shopping"
      )
    )
  }()

  static let mockList: [TransactionModel] = {
    let calendar = Calendar.current
    let now = Date()

    return [
      // August 2025 - Expenses
      TransactionModel(
        id: UUID(uuidString: "44e01127-913d-4778-9120-41eb8d352015")!,
        createdAt: "2025-08-01T13:15:33.60387+00:00",
        description: "Peralatan badminton",
        amount: 244000,
        categoryId: 13,
        accountId: "b43de564-e6cd-4a76-9f49-25e95c4e2a5f",
        accountName: "Jago Utama (509416230592)",
        spentAt: "2025-08-01T13:15:21.738+00:00",
        type: .expense,
        category: TransactionCategory(id: 13, iconName: "bag.fill", name: "Shopping")
      ),
      TransactionModel(
        id: UUID(uuidString: "dd5e05ba-4926-4021-ac0b-d81930db7c80")!,
        createdAt: "2025-08-01T10:25:24.113152+00:00",
        description: "Cicilan iPhone 16 Pro",
        amount: 1561344,
        categoryId: 23,
        accountId: "b43de564-e6cd-4a76-9f49-25e95c4e2a5f",
        accountName: "Jago Utama (509416230592)",
        spentAt: "2025-08-01T10:25:12.905+00:00",
        type: .expense,
        category: TransactionCategory(id: 23, iconName: "creditcard", name: "Installment")
      ),

      // Recent transactions - October 2025
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -1, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Dinner at The Harvest",
        amount: 385000,
        categoryId: 9,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -1, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 9, iconName: "fork.knife", name: "Food & Dining")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -1, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Grab to Office",
        amount: 45000,
        categoryId: 15,
        accountId: UUID().uuidString,
        accountName: "GoPay",
        spentAt: calendar.date(byAdding: .day, value: -1, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 15, iconName: "car.fill", name: "Transportation")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -2, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Monthly Salary",
        amount: 15000000,
        categoryId: 1,
        accountId: UUID().uuidString,
        accountName: "Mandiri Salary",
        spentAt: calendar.date(byAdding: .day, value: -2, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .income,
        category: TransactionCategory(id: 1, iconName: "banknote.fill", name: "Salary")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -3, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Netflix Subscription",
        amount: 186000,
        categoryId: 18,
        accountId: UUID().uuidString,
        accountName: "BCA Credit Card",
        spentAt: calendar.date(byAdding: .day, value: -3, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 18, iconName: "play.tv.fill", name: "Entertainment")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -4, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Indomaret Shopping",
        amount: 127500,
        categoryId: 10,
        accountId: UUID().uuidString,
        accountName: "Jago Utama (509416230592)",
        spentAt: calendar.date(byAdding: .day, value: -4, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 10, iconName: "cart.fill", name: "Groceries")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -5, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Electric Bill PLN",
        amount: 456000,
        categoryId: 20,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -5, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 20, iconName: "bolt.fill", name: "Utilities")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -6, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Coffee with Team",
        amount: 95000,
        categoryId: 9,
        accountId: UUID().uuidString,
        accountName: "GoPay",
        spentAt: calendar.date(byAdding: .day, value: -6, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 9, iconName: "cup.and.saucer.fill", name: "Food & Dining")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -7, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Gym Membership",
        amount: 500000,
        categoryId: 25,
        accountId: UUID().uuidString,
        accountName: "Mandiri Debit",
        spentAt: calendar.date(byAdding: .day, value: -7, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 25, iconName: "figure.walk", name: "Health & Fitness")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -8, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Freelance Project Payment",
        amount: 5000000,
        categoryId: 2,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -8, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .income,
        category: TransactionCategory(id: 2, iconName: "laptopcomputer", name: "Freelance")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -9, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Split Bill - Team Lunch",
        amount: 150000,
        categoryId: 9,
        accountId: UUID().uuidString,
        accountName: "GoPay",
        spentAt: calendar.date(byAdding: .day, value: -9, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .split_bill,
        category: TransactionCategory(id: 9, iconName: "fork.knife", name: "Food & Dining")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -10, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Transfer to Savings",
        amount: 2000000,
        categoryId: 30,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -10, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .transfer,
        category: TransactionCategory(id: 30, iconName: "arrow.left.arrow.right", name: "Transfer")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -11, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Phone Credit Top-up",
        amount: 100000,
        categoryId: 21,
        accountId: UUID().uuidString,
        accountName: "GoPay",
        spentAt: calendar.date(byAdding: .day, value: -11, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 21, iconName: "phone.fill", name: "Phone & Internet")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -12, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Tokopedia Shopping",
        amount: 678000,
        categoryId: 13,
        accountId: UUID().uuidString,
        accountName: "BCA Credit Card",
        spentAt: calendar.date(byAdding: .day, value: -12, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 13, iconName: "bag.fill", name: "Shopping")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -13, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Medicine at Guardian",
        amount: 235000,
        categoryId: 26,
        accountId: UUID().uuidString,
        accountName: "Jago Utama (509416230592)",
        spentAt: calendar.date(byAdding: .day, value: -13, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 26, iconName: "cross.case.fill", name: "Healthcare")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -14, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Movie Tickets",
        amount: 120000,
        categoryId: 18,
        accountId: UUID().uuidString,
        accountName: "GoPay",
        spentAt: calendar.date(byAdding: .day, value: -14, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 18, iconName: "film.fill", name: "Entertainment")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -15, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Gas Station",
        amount: 300000,
        categoryId: 16,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -15, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 16, iconName: "fuelpump.fill", name: "Vehicle")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -16, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Book Purchase on Amazon",
        amount: 420000,
        categoryId: 27,
        accountId: UUID().uuidString,
        accountName: "BCA Credit Card",
        spentAt: calendar.date(byAdding: .day, value: -16, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 27, iconName: "book.fill", name: "Education")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -17, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Investment Returns",
        amount: 1250000,
        categoryId: 3,
        accountId: UUID().uuidString,
        accountName: "Mandiri Salary",
        spentAt: calendar.date(byAdding: .day, value: -17, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .income,
        category: TransactionCategory(id: 3, iconName: "chart.line.uptrend.xyaxis", name: "Investment")
      ),
      TransactionModel(
        id: UUID(),
        createdAt: calendar.date(byAdding: .day, value: -18, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        description: "Restaurant - Birthday Celebration",
        amount: 850000,
        categoryId: 9,
        accountId: UUID().uuidString,
        accountName: "BCA Digital",
        spentAt: calendar.date(byAdding: .day, value: -18, to: now)?.ISO8601Format() ?? now.ISO8601Format(),
        type: .expense,
        category: TransactionCategory(id: 9, iconName: "fork.knife", name: "Food & Dining")
      )
    ]
  }()

  // MARK: - Filtered Mock Lists
  static var mockExpenses: [TransactionModel] {
    mockList.filter { $0.type == .expense }
  }

  static var mockIncome: [TransactionModel] {
    mockList.filter { $0.type == .income }
  }

  static var mockTransfers: [TransactionModel] {
    mockList.filter { $0.type == .transfer }
  }

  static var mockSplitBills: [TransactionModel] {
    mockList.filter { $0.type == .split_bill }
  }
}
