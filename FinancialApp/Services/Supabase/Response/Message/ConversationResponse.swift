//
//  ConversationResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 23/10/25.
//

import Foundation

struct ConversationResponse: Codable {
  let id: String
  let userId: String?
  let agentId: String?
  let title: String?
  let createdAt: Date
  let lastMessageAt: Date?
  
  enum CodingKeys: String, CodingKey {
    case id, title
    case userId = "user_id"
    case agentId = "agent_id"
    case createdAt = "created_at"
    case lastMessageAt = "last_message_at"
  }
}
