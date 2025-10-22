//
//  NavigationTab.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

@MainActor
struct NavigationTab<Content: View>: View {
  @State private var routerPath = RouterPath()
  
  var content: () -> Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
      self.content = content
    }
  
  var body: some View {
    NavigationStack(path: $routerPath.path) {
      content()
        .withNavigationDestination()
        .toolbarVisibility(routerPath.path.isEmpty ? .visible : .hidden, for: .tabBar)
    }
    .environment(routerPath)
  }
}
