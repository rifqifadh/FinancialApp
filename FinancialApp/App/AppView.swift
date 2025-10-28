//
//  AppView.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

struct AppView: View {
  @Binding var selectedTab: AppTab
  @State private var authStore = AuthenticationStore()
  @State private var chatTheme = ChatTheme()
   
  var body: some View {
    Group {
      if authStore.authState == .authenticated {
        TabView(selection: $selectedTab) {
          Tab("Dashboard", systemImage: "house", value: .dashboard) {
            NavigationTab {
              DashboardTab()
            }
          }
          
          Tab("Chat", systemImage: "message", value: .chats) {
            NavigationTab {
              ChatRoomsView()
                .chatTheme(chatTheme)
            }
          }
          
//          Tab("Transactions", systemImage: "dollarsign.circle", value: .transactions) {
//            NavigationTab {
//              TransactionView()
//            }
//          }
          
          Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
            NavigationTab {
              ProfileView()
            }
          }
        }
        .navigationViewStyle(StackNavigationViewStyle())
      } else if authStore.authState == .loading {
        LoadingView()
      }
      else {
        LoginView()
      }
    }
    .task {
      await authStore.checkAuthentication()
    }
  }
}

#Preview {
  AppView(selectedTab: .constant(.dashboard))
}

