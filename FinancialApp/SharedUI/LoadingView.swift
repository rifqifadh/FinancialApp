//
//  LoadingView.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import SwiftUI

struct LoadingView: View {
  let label: String?
  
  init(label: String? = nil) {
    self.label = label
  }
  
  var body: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      ProgressView()
        .scaleEffect(1.2)
      
      Text(label == nil ? "Loading..." : label!)
        .font(AppTheme.Typography.body)
        .foregroundStyle(AppTheme.Colors.secondaryText)
    }
  }
}
