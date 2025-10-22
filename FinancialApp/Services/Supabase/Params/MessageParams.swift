//
//  MessageParams.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Foundation

struct MessageParams: Encodable {
  let userId: String
  let channelId: String
  let name: String
  let avatarUrl: String?
  let content: String
  let role: Role
  let createdAt: Date
  
  enum Role: String, Sendable, Encodable {
    case user
  }
  
  enum CodingKeys: String, CodingKey {
    case userId, name, content, role
    case channelId = "channel_id"
    case avatarUrl = "avatar_url"
    case createdAt = "created_at"
  }
  
  init(userId: String, channelId: String, name: String, avatarUrl: String? = nil, content: String, role: Role = .user, createdAt: Date = .init()) {
    self.userId = userId
    self.channelId = channelId
    self.name = name
    self.avatarUrl = avatarUrl
    self.content = content
    self.role = role
    self.createdAt = createdAt
  }
}
