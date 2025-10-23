//
//  ChatMessageResponse.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  ChatResponse.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 18/07/25.
//

import Foundation

struct MessageResponse: Codable {
  let id: String
  let createdAt: Date?
  let conversationId: String?
  let role: String?
  let content: String
  let metadata: String?
  let userId: String?
  let agentId: String?
  
  init(id: String,
       createdAt: Date?,
       conversationId: String? = nil,
       role: String? = nil,
       content: String,
       metadata: String? = nil,
       userId: String? = nil,
       agentId: String? = nil) {
    self.id = id
    self.createdAt = createdAt
    self.conversationId = conversationId
    self.role = role
    self.content = content
    self.metadata = metadata
    self.userId = userId
    self.agentId = agentId
  }
  
  enum CodingKeys: String, CodingKey {
    case id, role, content, metadata
    case createdAt = "created_at"
    case conversationId = "conversation_id"
    case userId = "user_id"
    case agentId = "agent_id"
  }
}
