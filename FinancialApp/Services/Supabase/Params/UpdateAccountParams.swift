//
//  UpdateAccountParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

struct UpdateAccountParams: Codable, Sendable {
  let id: String
  let name: String
  let category: String
  let currency: String
  let accountNumber: String
  let finalBalance: Int?
  
  enum CodingKeys: String, CodingKey {
    case id = "account_id"
    case name
    case category
    case currency
    case accountNumber = "account_number"
    case finalBalance = "final_balance"
  }
}
