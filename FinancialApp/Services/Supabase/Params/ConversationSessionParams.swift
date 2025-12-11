//
//  ConversationSessionParams.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 09/12/25.
//


struct ConversationSessionParams: Encodable {
  let conversationId: String
  let userId: String
  let agents: [String: String]
  let lastActiveAgent: String?
  
  enum CodingKeys: String, CodingKey {
    case conversationId = "conversation_id"
    case userId = "user_id"
    case agents
    case lastActiveAgent = "last_active_agent"
  }
}
