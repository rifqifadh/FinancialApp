//
//  ChatRoom.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Foundation

struct ChatRoom: Codable, Identifiable, Sendable {
  let id: String
  let name: String
  let createdAt: Date?
  let userId: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case createdAt = "created_at"
    case userId = "user_id"
  }

  // MARK: - Mock Data
  static let mockList: [ChatRoom] = [
    ChatRoom(
      id: "1",
      name: "Expense Channel",
      createdAt: Date().addingTimeInterval(-86400 * 5),
      userId: "user1"
    )
  ]

  static let mock = mockList[0]
}

