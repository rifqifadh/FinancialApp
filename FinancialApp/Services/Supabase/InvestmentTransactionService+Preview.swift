//
//  InvestmentTransactionService+Preview.swift
//  FinancialApp
//
//  Created by Claude on 11/12/25.
//

import Dependencies
import Foundation

// MARK: - Preview Mock Implementation
extension InvestmentTransactionService {
    static let mockPreviewValue = InvestmentTransactionService(
        fetchAll: { investmentId in
            // Simulate network delay for realistic preview
            try? await Task.sleep(for: .milliseconds(250))
            let transactions = InvestmentTransactionModel.mockTransactions.filter { $0.investmentId == investmentId }
            print("📊 [Preview] Fetched \(transactions.count) transactions for investment: \(investmentId)")
            return transactions
        },
        fetchById: { id in
            try? await Task.sleep(for: .milliseconds(200))
            let transaction = InvestmentTransactionModel.mockTransactions.first { $0.id == id }
            if let transaction = transaction {
                print("📊 [Preview] Fetched transaction \(id): \(transaction.type.rawValue)")
            } else {
                print("📊 [Preview] Transaction \(id) not found")
            }
            return transaction
        },
        create: { params in
            try? await Task.sleep(for: .milliseconds(400))
            print("📝 [Preview] Created \(params.type) transaction: \(params.units) units @ \(params.pricePerUnit) = \(params.totalAmount)")
        },
        update: { id, params in
            try? await Task.sleep(for: .milliseconds(350))
            print("✏️ [Preview] Updated transaction \(id): \(params.type ?? "N/A") - \(params.totalAmount ?? 0)")
        },
        delete: { id in
            try? await Task.sleep(for: .milliseconds(300))
            print("🗑️ [Preview] Deleted transaction: \(id)")
        }
    )
}
