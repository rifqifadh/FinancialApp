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
