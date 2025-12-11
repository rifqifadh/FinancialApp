//
//  ConversationParams.swift
//  FinancialApp
//
//  Created by Rifqi on 08/12/25.
//

import Foundation

struct ConversationParams: Encodable {
  let title: String
  let userId: String
  let agentId: String?

  enum CodingKeys: String, CodingKey {
    case title
    case userId = "user_id"
    case agentId = "agent_id"
    
  }

  init(title: String, userId: String, agentId: String? = nil) {
    self.title = title
    self.userId = userId
    self.agentId = agentId
  }
}
