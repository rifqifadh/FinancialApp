//
//  TransactionType+Extensions.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

extension TransactionType {
  /// Returns the display label for the transaction type
  var label: String {
    switch self {
    case .expense: return "Expense"
    case .income: return "Income"
    case .transfer: return "Transfer"
    case .split_bill: return "Split Bill"
    }
  }

  /// Returns the SF Symbol icon name for the transaction type
  var icon: String {
    switch self {
    case .expense: return "arrow.down.circle.fill"
    case .income: return "arrow.up.circle.fill"
    case .transfer: return "arrow.left.arrow.right.circle.fill"
    case .split_bill: return "person.2.fill"
    }
  }

  /// Returns the theme color for the transaction type
  var color: Color {
    switch self {
    case .expense: return AppTheme.Colors.loss
    case .income: return AppTheme.Colors.profit
    case .transfer: return AppTheme.Colors.primary
    case .split_bill: return AppTheme.Colors.accent
    }
  }

  /// Returns the amount display color for the transaction type
  var amountColor: Color {
    switch self {
    case .expense: return AppTheme.Colors.loss
    case .income: return AppTheme.Colors.profit
    case .transfer: return AppTheme.Colors.primary
    case .split_bill: return AppTheme.Colors.primaryText
    }
  }
}

// MARK: - Hashable Conformance
extension TransactionType: Hashable {}
