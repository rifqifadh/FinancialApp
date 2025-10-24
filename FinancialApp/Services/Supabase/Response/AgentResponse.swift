//
//  AgentResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 24/10/25.
//

import Foundation

struct AgentResponse: Codable, Equatable {
  let id: String
  let createdAt: Date?
  let updatedAt: Date?
  let name: String
  let modelName: String?
  
  enum CodingKeys: String, CodingKey {
    case id, name
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case modelName = "model_name"
  }
}
