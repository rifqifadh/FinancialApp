//
//  QuickActionsView.swift
//  FinancialApp
//
//  Created by Claude on 11/12/25.
//

import SwiftUI

enum QuickAction: Identifiable {
  case buyMore
  case sell
  case dividend
  case updateValue
  case recordCoupon
  
  var id: String {
    switch self {
    case .buyMore: return "buy_more"
    case .sell: return "sell"
    case .dividend: return "dividend"
    case .updateValue: return "update_value"
    case .recordCoupon: return "record_coupon"
    }
  }
  
  var title: String {
    switch self {
    case .buyMore: return "Buy More"
    case .sell: return "Sell"
    case .dividend: return "Dividend"
    case .updateValue: return "Update Value"
    case .recordCoupon: return "Coupon"
    }
  }
  
  var icon: String {
    switch self {
    case .buyMore: return "plus.circle.fill"
    case .sell: return "arrow.up.circle.fill"
    case .dividend: return "dollarsign.circle.fill"
    case .updateValue: return "arrow.triangle.2.circlepath"
    case .recordCoupon: return "doc.text.fill"
    }
  }
  
  var color: Color {
    switch self {
    case .buyMore: return AppTheme.Colors.accent
    case .sell: return AppTheme.Colors.profit
    case .dividend: return AppTheme.Colors.profit
    case .updateValue: return AppTheme.Colors.accent
    case .recordCoupon: return AppTheme.Colors.profit
    }
  }
}

struct QuickActionsView: View {
  let investment: InvestmentResponse
  let onAction: (QuickAction) -> Void
  
  var availableActions: [QuickAction] {
    switch investment.type {
    case .stocks, .reksaDanaSaham, .reksaDanaCampuran:
      return [.buyMore, .sell, .dividend]
      
    case .deposito:
      if investment.isMatured {
        return [.updateValue]
      }
      return []
      
    case .obligation, .sukuk:
      return [.recordCoupon]
      
    case .reksaDanaPasarUang, .reksaDanaPendapatanTetap:
      return [.buyMore, .sell]
      
    default:
      return []
    }
  }
  
  var body: some View {
    if !availableActions.isEmpty {
      VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
        Text("Quick Actions")
          .font(AppTheme.Typography.bodyBold)
          .foregroundStyle(AppTheme.Colors.primaryText)
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(availableActions) { action in
              QuickActionButton(action: action) {
                onAction(action)
              }
            }
          }
        }
      }
      .padding(AppTheme.Spacing.lg)
      .background(AppTheme.Colors.cardBackground)
      .cornerRadius(AppTheme.CornerRadius.medium)
      .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
  }
}

struct QuickActionButton: View {
  let action: QuickAction
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      VStack(spacing: AppTheme.Spacing.xs) {
        Image(systemName: action.icon)
          .font(.system(size: 24))
          .foregroundStyle(action.color)
          .frame(width: 50, height: 50)
          .background(action.color.opacity(0.1))
          .clipShape(Circle())
        
        Text(action.title)
          .font(AppTheme.Typography.caption)
          .foregroundStyle(AppTheme.Colors.primaryText)
      }
      .frame(width: 80)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack(spacing: 20) {
    QuickActionsView(investment: .mockStocks) { action in
      print("Action: \(action.title)")
    }
    
    QuickActionsView(investment: .mockDeposito) { action in
      print("Action: \(action.title)")
    }
  }
  .padding()
  .background(AppTheme.Colors.background)
}
