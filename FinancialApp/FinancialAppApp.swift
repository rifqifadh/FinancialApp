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
  var body: some Scene {
    WindowGroup {
      RootView()
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
