//
//  FinancialAppApp.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import SwiftUI
import GoogleSignIn
import Dependencies

@main
struct FinancialAppApp: App {
  @State var selectedTab: AppTab = .dashboard
  
  init() {
//    prepareDependencies { dep in
//      dep.investmentService = InvestmentService.mockPreviewValue
//      dep.investmentTransactionService = InvestmentTransactionService.mockPreviewValue
//    }
  }
  var body: some Scene {
    WindowGroup {
      AppView(selectedTab: $selectedTab)
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
