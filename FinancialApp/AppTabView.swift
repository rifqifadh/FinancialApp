//
//  AppTabView.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  NavigationBarView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 18/07/25.
//

import SwiftUI

struct AppTabView: View {
  @Environment(AppNavigation.self) var appNavigation
  
  var body: some View {
      TabView {
        TransactionView()
          .tabItem {
            Label("Expenses", systemImage: "dollarsign.circle")
          }

        AccountsView()
          .tabItem {
            Label("Accounts", systemImage: "wallet.pass")
          }

//        ChatRoomView(viewModel: chatViewModel)
//          .tabItem {
//            Label("Chat", systemImage: "message")
//          }

        NavigationView {
          Text("LKJLKJLKJ")
//          InvestmentsView(viewModel: investmentsViewModel)
        }
        .tabItem {
          Label("Porto", systemImage: "chart.line.uptrend.xyaxis")
        }

        ProfileView()
          .tabItem {
            Label("Profile", systemImage: "gear")
          }
      }
  }
}

struct SettingsView: View {
    
  var body: some View {
      VStack {
          Text("Settings Tab")
          Button("Logout") {
              Task {
//                  try await mySupabaseClient.auth.signOut()
              }
          }
      }
    
  }
}
