//
//  RootView.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  RootView.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 18/07/25.
//

import SwiftUI
import Supabase
import Foundation
import Dependencies

struct RootView: View {
  @Bindable var appNavigation = AppNavigation()
  @State var authStore = AuthenticationStore()
  
  init() {
    
  }
  
  var body: some View {
    Group {
      NavigationStack(path: $appNavigation.path) {
        AppTabView()
          .navigationBarBackButtonHidden()
        LoadingView()
          .navigationDestination(for: AppRouter.self) { destination in
            switch destination {
            case .viewOne:
              Text("LMAOO")
            case .viewTwo:
              Text("View Two")
            case .investments:
              Text("Investment List View")
              //                            InvestmentListView(investments: Investment.mockData)
            case .investmentDetail(let id):
              Text("Investment Detail View for ID: \(id)")
              //                            InvestmentDetailView(id: id)
//            case .accounts:
//              Text("Account List View")
//            case .accountDetail(let id):
//              Text("Account Detail View for ID: \(id)")
            case .login:
              LoginView()
                .navigationBarBackButtonHidden()
            case .appTab:
              AppTabView()
                .navigationBarBackButtonHidden()
            }
          }
        
      }
      .onChange(of: authStore.authState) { oldValue, newValue in
        if oldValue == .loading && newValue == .authenticated {
          //                    appNavigation.push(.appTab)
          appNavigation.path = [.appTab]
        } else if oldValue == .loading && newValue == .unauthenticated {
          //                    appNavigation.push(.login)cha
          appNavigation.path = [.login]
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
    
    .environment(appNavigation)
    .task {
      await authStore.checkAuthentication()
    }
  }
}

struct LoadingView: View {
  
  var body: some View {
    VStack {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
        .padding()
      Text("Loading...")
        .font(.headline)
        .foregroundColor(.gray)
    }
  }
}
