//
//  ExpensesViewModel.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 17/07/25.
//

import Observation
import Dependencies
import Foundation

@Observable
@MainActor
class ExpensesViewModel {
  @ObservationIgnored
  @Dependency(\.expenseService) var expenseService
  
  var expenses: [ExpenseResponse] = []
  var totalExpense: String = ""
  var isLoading: Bool = false
  var selectedMonth: Date = .now
  var selectedCategory: [Int]?
  let months = Calendar.current.monthSymbols
  
  init() {
    
    //        Task {
    //            await initialFetch()
    //        }
  }
  
  func refresh() async {
    //		do {
    //			try await fetchExpenses(month: selectedMonth)
    //		} catch {
    //			print(error)
    //		}
  }
  
  func initialFetch() async {
    //		do {
    //			isLoading = true
    //			try await fetchExpenses()
    //			isLoading = false
    //		} catch {
    //			print(error)
    //			isLoading = false
    //		}
  }
  
  func fetch(month: Date = .now, categoryIDs: [Int]? = nil) async throws {
    		do {
    			let res = try await expenseService.fetchAll(.init(date: month, categoryIDs: categoryIDs))
    			expenses = res.records ?? []
    			totalExpense = "Rp 0"
    		} catch {
    			print(error)
    			throw error
    		}
  }
  
  func delete(_ id: UUID) async throws {
    		do {
          try await expenseService.deleteById(id.uuidString)
    		} catch {
    			throw error
    		}
  }
}
