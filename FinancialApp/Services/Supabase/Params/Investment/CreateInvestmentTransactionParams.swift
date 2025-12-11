//
//  CreateInvestmentTransactionParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 10/12/25.
//


struct CreateInvestmentTransactionParams: Codable, Sendable {
    let investmentId: String
    let type: String
    let units: Double
    let pricePerUnit: Int
    let totalAmount: Int
    let transactionDate: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case investmentId = "investment_id"
        case type
        case units
        case pricePerUnit = "price_per_unit"
        case totalAmount = "total_amount"
        case transactionDate = "transaction_date"
        case notes
    }
}