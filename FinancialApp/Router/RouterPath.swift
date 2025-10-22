//
//  RouterPath.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Observation

@MainActor
@Observable
final class RouterPath {
  var path: [RouterDestination] = []
  
  func navigate(to: RouterDestination) {
    path.append(to)
  }
  
  func pop() {
    _ = path.popLast()
  }
  
  func popToRoot() {
    path.removeAll()
  }
}
