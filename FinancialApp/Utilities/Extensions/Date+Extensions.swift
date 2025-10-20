//
//  Date+Extensions.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import Foundation

extension Date {
  func toStringNonIsolated() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .current
    formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
    return formatter.string(from: self)
  }
  
  func startOfDay() -> Date {
    Calendar.current.startOfDay(for: self)
  }
  
  func isSameDay(_ date: Date) -> Bool {
    Calendar.current.isDate(self, inSameDayAs: date)
  }
  
  static let iso8601Date = Date.ISO8601FormatStyle.iso8601.year().month().day()

  /// Formats the date using the specified format string
  /// - Parameter format: The date format string (e.g., "yyyy-MM-dd", "MMMM yyyy")
  /// - Returns: Formatted date string
  func formatted(_ format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }

  /// Formats the date as time (HH:mm)
  /// - Returns: Time string in HH:mm format
  func formattedTime() -> String {
    formatted("HH:mm")
  }
}

extension DateFormatter {
  
  static let timeFormatter = {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    
    return formatter
  }()
  
  static let relativeDateFormatter = {
    let relativeDateFormatter = DateFormatter()
    relativeDateFormatter.timeStyle = .none
    relativeDateFormatter.dateStyle = .full
    relativeDateFormatter.doesRelativeDateFormatting = true
    
    return relativeDateFormatter
  }()
  
  static func timeString(_ seconds: Int) -> String {
    let hour = Int(seconds) / 3600
    let minute = Int(seconds) / 60 % 60
    let second = Int(seconds) % 60
    
    if hour > 0 {
      return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    return String(format: "%02i:%02i", minute, second)
  }
}

// MARK: - String Date Extensions
extension String {
  /// Parses an ISO8601 date string to Date
  /// - Returns: Date object or current date if parsing fails
  func toDate() -> Date {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: self) ?? Date()
  }

  /// Formats an ISO8601 date string using the specified format
  /// - Parameter format: The date format string
  /// - Returns: Formatted date string
  func formatDate(_ format: String) -> String {
    toDate().formatted(format)
  }

  /// Formats an ISO8601 date string as time (HH:mm)
  /// - Returns: Time string in HH:mm format
  func formatTime() -> String {
    toDate().formattedTime()
  }

  /// Converts a yyyy-MM-dd string to a formatted date string
  /// - Parameter format: The output date format string
  /// - Returns: Formatted date string
  func formatDateString(_ format: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = format

    if let date = inputFormatter.date(from: self) {
      return outputFormatter.string(from: date)
    }
    return self
  }
}
