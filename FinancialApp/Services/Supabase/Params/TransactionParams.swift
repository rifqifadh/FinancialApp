//
//  TransactionParams.swift
//  FinancialApp
//
//  Created by Rifqi on 25/10/25.
//

import Foundation

struct TransactionParams: Encodable, Sendable {
  let month: Date
  let accountId: String?
  
  enum CodingKeys: String, CodingKey {
    case month
    case accountId = "account_id"
  }
  
  init(month: Date = .now, accountId: String? = nil) {
    self.month = month
    self.accountId = accountId
  }
}
