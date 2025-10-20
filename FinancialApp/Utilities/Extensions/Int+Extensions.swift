//
//  Int+Extensions.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Foundation

extension Int {
  /// Formats the integer as Indonesian Rupiah currency
  /// - Returns: Formatted currency string (e.g., "Rp1.234.567")
  func toCurrency() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "Rp"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: self)) ?? "Rp0"
  }

  /// Formats the integer as currency with a custom symbol
  /// - Parameter symbol: The currency symbol to use
  /// - Returns: Formatted currency string
  func toCurrency(symbol: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = symbol
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: self)) ?? "\(symbol)0"
  }

  /// Formats the integer with thousand separators
  /// - Returns: Formatted number string (e.g., "1.234.567")
  func toFormattedString() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "."
    formatter.decimalSeparator = ","
    return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
  }
}
