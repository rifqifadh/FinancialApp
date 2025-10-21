//
//  UpdateAccountParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

struct UpdateAccountParams: Codable, Sendable {
  let name: String?
  let category: String?
  let accountNumber: String?
  let finalBalance: Int?
  let currency: String?
  
  enum CodingKeys: String, CodingKey {
    case name
    case category
    case currency
    case accountNumber = "account_number"
    case finalBalance = "final_balance"
  }
}
