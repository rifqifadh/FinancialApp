//
//  AppNavigation.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  AppState.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 18/07/25.
//

import SwiftUI
import Supabase

@Observable
class AppNavigation {
  var path: [AppRouter] = []
  
  var currentRouter: AppRouter? {
    path.last
  }
  
  func push(_ router: AppRouter) {
    path.append(router)
  }
  
  func pop() {
    if !path.isEmpty {
      path.removeLast()
    }
  }
  
  func popToRoot() {
    path.removeAll()
  }
  
  func popTo(_ router: AppRouter) {
    if let index = path.firstIndex(of: router) {
      path = Array(path.prefix(upTo: index + 1))
    }
  }
}
