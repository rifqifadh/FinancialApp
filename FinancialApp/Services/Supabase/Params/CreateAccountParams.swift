//
//  CreateAccountParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import Foundation

// MARK: - Request Parameters
struct CreateAccountParams: Codable, Sendable {
    let name: String
    let category: String
    let currency: String
    let accountNumber: String
    let initialBalance: Int
    let finalBalance: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case currency
        case accountNumber = "account_number"
        case initialBalance = "initial_balance"
        case finalBalance = "final_balance"
    }
}
