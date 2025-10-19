//
//  ExpenseResponse.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  ExpenseResponse.swift
//  aurum-track
//
//  Created by Rifqi on 01/07/25.
//

import Foundation

struct ExpenseResponse: Codable {
    let id: UUID
    let createdAt: String
    let description: String
    let amount: Int
    let categoryId: Int
    let bankAccountId: String
    let bankAccountName: String
    let spentAt: String
    let category: ExpenseCategoryResponse?
    
  enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case amount
        case categoryId = "category_id"
        case bankAccountId = "bank_account_id"
        case bankAccountName = "bank_account_name"
        case spentAt = "spent_at"
        case category
    }
}

extension ExpenseResponse {
    static let mock: ExpenseResponse = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime]
        
        return ExpenseResponse(
            id: UUID(),
            createdAt: Date.now.description,
            description: "Coffee with colleagues",
            amount: 4500,
            categoryId: 2,
            bankAccountId: UUID().uuidString,
            bankAccountName: "BCA",
            spentAt: Date.now.description,
            category: .init(id: 9, iconName: "fork.knife", name: "Food & Drink")
        )
    }()
    
    static let mockList: [ExpenseResponse] = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime]
        
        return [
            .mock,
            ExpenseResponse(
                id: UUID(),
                createdAt: Date.now.description,
                description: "Office supplies",
                amount: 12300,
                categoryId: 5,
                bankAccountId: UUID().uuidString,
                bankAccountName: "Jago Utama",
                spentAt: Date.now.description,
                category: .init(id: 9, iconName: "fork.knife", name: "Food & Drink")
            )
        ]
    }()
}
