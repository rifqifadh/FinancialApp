//
//  TransactionCategory.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import Foundation

struct TransactionCategory: Codable, Hashable {
  let id: Int
  let iconName: String?
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case iconName = "icon_name"
    case name
  }
  
  init(id: Int, iconName: String?, name: String) {
    self.id = id
    self.iconName = iconName
    self.name = name
  }
}
