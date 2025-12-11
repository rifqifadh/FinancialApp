//
//  UpdateInvestmentParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 10/12/25.
//


struct UpdateInvestmentParams: Codable, Sendable {
    let name: String?
    let type: String?
    let accountId: String?
    let currentValue: Int?
    let maturityDate: String?
    let interestRate: Double?
    let units: Double?
    let pricePerUnit: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case accountId = "account_id"
        case currentValue = "current_value"
        case maturityDate = "maturity_date"
        case interestRate = "interest_rate"
        case units
        case pricePerUnit = "price_per_unit"
        case notes
    }
}