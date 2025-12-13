//
//  InvestmentService+Preview.swift
//  FinancialApp
//
//  Created by Claude on 11/12/25.
//

import Dependencies
import Foundation

// MARK: - Preview Mock Implementation
extension InvestmentService {
    static let mockPreviewValue = InvestmentService(
        fetchAll: {
            // Simulate network delay for realistic preview
            try? await Task.sleep(for: .milliseconds(300))
            return InvestmentResponse.mockInvestments
        },
        fetchById: { id in
            try? await Task.sleep(for: .milliseconds(200))
            return InvestmentResponse.mockInvestments.first { $0.id == id }
        },
        create: { params in
            try? await Task.sleep(for: .milliseconds(500))
            print("📝 [Preview] Created investment: \(params.name)")
            return "preview-investment-id-\(UUID().uuidString)"
        },
        update: { id, params in
            try? await Task.sleep(for: .milliseconds(400))
            print("✏️ [Preview] Updated investment \(id): \(params.name ?? "N/A")")
        },
        delete: { id in
            try? await Task.sleep(for: .milliseconds(300))
            print("🗑️ [Preview] Deleted investment: \(id)")
        },
        updateCurrentValue: { id, currentValue in
            try? await Task.sleep(for: .milliseconds(300))
            print("💰 [Preview] Updated current value for \(id): \(currentValue)")
        }
    )
}
