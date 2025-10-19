//
//  MessagesSection.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//


import Foundation


struct MessagesSection: Equatable, @unchecked Sendable {

    let date: Date
    var rows: [MessageRow]

    init(date: Date, rows: [MessageRow]) {
        self.date = date
        self.rows = rows
    }

    var formattedDate: String {
        DateFormatter.relativeDateFormatter.string(from: date)
    }

    static func == (lhs: MessagesSection, rhs: MessagesSection) -> Bool {
        lhs.date == rhs.date && lhs.rows == rhs.rows
    }
}
