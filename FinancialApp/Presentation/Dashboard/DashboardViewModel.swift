//
//  DashboardViewModel.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import Observation
import Dependencies

@MainActor
@Observable final class DashboardViewModel {
  @ObservationIgnored
  @Dependency(\.dashboardServices) private var dashboardServices
  
  var summaryState: ViewState<DashboardSummary> = .idle
  
  init() {}
  
  func loadSummary() async {
    do {
      summaryState = .loading
      let summary = try await dashboardServices.fetchSummary()
      
        summaryState = .success(summary.data!)
    } catch {
      summaryState = .error(error)
    }
  }
}
