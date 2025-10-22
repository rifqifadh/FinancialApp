//
//  RouterDestination.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

enum RouterDestination: Hashable {
  case accounts
  case accountDetail(id: String)
  case investments
  case investmentDetail(id: String)
  case chatRoom(id: String)
}
