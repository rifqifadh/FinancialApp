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
//  @State private var viewModel = ExpensesViewModel()
//  @State private var chatViewModel = ChatRoomViewModel()
//  @State private var investmentsViewModel = InvestmentsViewModel()
  
  var body: some View {
      TabView {
//        ExpensesView(viewModel: viewModel)
//          .tabItem {
//            Label("Expenses", systemImage: "dollarsign.circle")
//          }
        
//        ChatRoomView(viewModel: chatViewModel)
//          .tabItem {
//            Label("Chat", systemImage: "message")
//          }
        
        NavigationView {
//          InvestmentsView(viewModel: investmentsViewModel)
        }
        .tabItem {
          Label("Porto", systemImage: "chart.line.uptrend.xyaxis")
        }
        
        SettingsView()
          .tabItem {
            Label("Settings", systemImage: "gear")
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
