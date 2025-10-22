//
//  FinancialAppApp.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import SwiftUI
import GoogleSignIn

@main
struct FinancialAppApp: App {
  @State var selectedTab: AppTab = .dashboard
  
  var body: some Scene {
    WindowGroup {
      AppView(selectedTab: $selectedTab)
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
