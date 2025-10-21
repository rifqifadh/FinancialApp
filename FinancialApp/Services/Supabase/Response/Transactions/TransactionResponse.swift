//
//  TransactionResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Foundation

struct TransactionResponse: Codable {
  let data: [TransactionModel]
  let totalIncome: Double
  let totalExpense: Double
  
  enum CodingKeys: String, CodingKey {
    case data
    case totalIncome = "total_income"
    case totalExpense = "total_expense"
  }
}
