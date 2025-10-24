//
//  MessageParams.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Foundation

struct MessageParams: Encodable {
  let conversationId: Int
  let role: Role
  let content: String
  let userId: String
  
  enum Role: String, Sendable, Encodable {
    case user
  }
  
  enum CodingKeys: String, CodingKey {
    case role, content
    case conversationId = "conversation_id"
    case userId = "user_id"
  }
  
  init(conversationId: Int, role: Role, content: String, userId: String) {
    self.conversationId = conversationId
    self.role = role
    self.content = content
    self.userId = userId
  }
}
