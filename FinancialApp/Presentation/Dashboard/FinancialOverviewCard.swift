//
//  FinancialOverviewCard.swift
//  FinancialApp
//
//  Created by Rifqi on 22/10/25.
//

import SwiftUI

struct FinancialOverviewCard: View {
  @AppStorage("isPrivacyModeEnabled") private var isPrivacyModeEnabled: Bool = false
  
  let totalAssets: Double
  let totalIncome: Double
  let totalExpense: Double
  
  var body: some View {
    VStack(spacing: AppTheme.Spacing.md) {
      // Header with Hide/Show Toggle
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Total Assets")
            .font(AppTheme.Typography.subheadline)
            .foregroundStyle(AppTheme.Colors.secondaryText)
          
          Text(totalAssets.toCurrency())
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.primaryText)
            .redacted(reason: isPrivacyModeEnabled ? .placeholder : [])
        }
        
        Spacer()
        
        // Toggle Button
        Button {
          withAnimation(.spring(response: 0.3)) {
            isPrivacyModeEnabled.toggle()
          }
        } label: {
          Image(systemName: isPrivacyModeEnabled ? "eye.slash.fill" : "eye.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.accent)
            .frame(width: 40, height: 40)
            .background(AppTheme.Colors.accent.opacity(0.1))
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
      
      // Income vs Expense
      HStack(spacing: AppTheme.Spacing.lg) {
        // Income
        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 6) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 16))
              .foregroundStyle(AppTheme.Colors.profit)
            
            Text("Income per month")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          Text(totalIncome.toCurrency())
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.profit)
            .redacted(reason: isPrivacyModeEnabled ? .placeholder : [])
        }
        
        Spacer()
        
        // Expense
        VStack(alignment: .trailing, spacing: 8) {
          HStack(spacing: 6) {
            Image(systemName: "arrow.up.circle.fill")
              .font(.system(size: 16))
              .foregroundStyle(AppTheme.Colors.loss)
            
            Text("Expense per month")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          Text(totalExpense.toCurrency())
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.loss)
            .redacted(reason: isPrivacyModeEnabled ? .placeholder : [])
        }
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
  }
}

extension FinancialOverviewCard {
  
  static func empty() -> FinancialOverviewCard {
    FinancialOverviewCard(
      totalAssets: 0,
      totalIncome: 0,
      totalExpense: 0
    )
  }
}
