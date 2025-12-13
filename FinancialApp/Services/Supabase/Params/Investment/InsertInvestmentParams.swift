//
//  CreateInvestmentParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 10/12/25.
//

struct InsertInvestmentParams: Codable, Sendable {
  let name: String
  let type: String
  let accountId: String?
  let initialAmount: Double
  let currentValue: Double
  let purchaseDate: String
  let maturityDate: String?
  let interestRate: Double?
  let units: Double?
  let initialPricePerUnit: Double?
  let pricePerUnit: Double?
  let notes: String?

  enum CodingKeys: String, CodingKey {
    case name
    case type
    case accountId = "account_id"
    case initialAmount = "initial_amount"
    case currentValue = "current_value"
    case purchaseDate = "purchase_date"
    case maturityDate = "maturity_date"
    case interestRate = "interest_rate"
    case units
    case initialPricePerUnit = "initial_price_per_unit"
    case pricePerUnit = "price_per_unit"
    case notes
  }
}
