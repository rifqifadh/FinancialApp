//
//  ExpensesSummaryResponse.swift
//  ExpenseTracker
//
//  Created by Rifqi on 08/07/25.
//

struct ExpensesSummaryResponse: Codable {
    let total: Int
    let records: [ExpenseResponse]?
}

extension ExpensesSummaryResponse {
    static let mock: ExpensesSummaryResponse = .init(
        total: 1000,
        records: [
            .mock
        ]
    )
}
