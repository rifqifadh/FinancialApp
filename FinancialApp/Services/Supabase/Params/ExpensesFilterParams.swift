//
//  ExpenseSummaryParams.swift
//  ExpenseTracker
//
//  Created by Rifqi on 08/07/25.
//

import Foundation

struct ExpensesFilterParams: Encodable, Sendable {
  let date: String
  let categoryIDs: [Int]?
  let bankAccountID: Int64?
  
  enum CodingKeys: String, CodingKey {
    case date = "date"
    case categoryIDs = "category_ids"
    case bankAccountID = "account_id"
  }
  
  init(date: Date, categoryIDs: [Int]? = nil, bankAccountID: Int64? = nil) {
    self.date = date.toStringNonIsolated()
    self.categoryIDs = categoryIDs
    self.bankAccountID = bankAccountID
  }
}
