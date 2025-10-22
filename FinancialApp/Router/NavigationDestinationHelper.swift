//
//  NavigationDestinationHelper.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

extension View {
  func withNavigationDestination() -> some View {
    self.navigationDestination(for: RouterDestination.self) { destination in
      switch destination {
      case .accounts: AccountsView()
      case .accountDetail(let id): AccountDetailView(accountId: id)
      case .investments: InvestmentsView()
      case .investmentDetail(let id): InvestmentDetailView(investmentId: id)
      case .chatRoom(let id): ChatRoomView(id: id)
      default: Text("Empty Navigation Destination")
      }
    }
  }
}
