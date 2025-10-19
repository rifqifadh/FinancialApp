//
//  ExpenseCategory.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


struct ExpenseCategoryResponse: Codable {
  let id: Int
  let iconName: String
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case iconName = "icon_name"
    case name
  }
}
