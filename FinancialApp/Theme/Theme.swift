//
//  Theme.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//

import SwiftUI

// MARK: - App Theme
struct AppTheme {
  
  // MARK: - Color Palette
  struct Colors {
    
    // Primary Colors - Professional Blue/Teal for Finance
    static let primary = Color("Primary")
    static let primaryLight = Color("PrimaryLight")
    static let primaryDark = Color("PrimaryDark")
    
    // Secondary Colors - Complementary Green for positive values
    static let secondary = Color("Secondary")
    static let secondaryLight = Color("SecondaryLight")
    static let secondaryDark = Color("SecondaryDark")
    
    // Accent Colors
    static let accent = Color("Accent")
    
    // Semantic Colors for Financial Data
    static let profit = Color("Profit")      // Green for gains
    static let loss = Color("Loss")          // Red for losses
    static let neutral = Color("Neutral")    // Gray for neutral
    
    // Background Colors
    static let background = Color("Background")
    static let secondaryBackground = Color("SecondaryBackground")
    static let tertiaryBackground = Color("TertiaryBackground")
    
    // Card/Surface Colors
    static let cardBackground = Color("CardBackground")
    static let elevatedCard = Color("ElevatedCard")
    
    // Text Colors
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let tertiaryText = Color("TertiaryText")
    
    // Border & Divider
    static let border = Color("Border")
    static let divider = Color("Divider")
    
    // Chart Colors
    static let chartColors = [
      Color("Chart1"),
      Color("Chart2"),
      Color("Chart3"),
      Color("Chart4"),
      Color("Chart5")
    ]
  }
  
  // MARK: - Typography
  struct Typography {
    // Headers
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body Text
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmallBold = Font.system(size: 14, weight: .semibold, design: .default)
    
    // Financial Numbers - Using monospaced for better alignment
    static let financialLarge = Font.system(size: 32, weight: .bold, design: .rounded).monospacedDigit()
    static let financialMedium = Font.system(size: 24, weight: .semibold, design: .rounded).monospacedDigit()
    static let financialSmall = Font.system(size: 17, weight: .medium, design: .default).monospacedDigit()
    
    // Supporting Text
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
  }
  
  // MARK: - Spacing
  struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
  }
  
  // MARK: - Corner Radius
  struct CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
  }
  
  // MARK: - Shadows
  struct Shadows {
    static let card = Color.black.opacity(0.08)
    static let elevated = Color.black.opacity(0.12)
  }
}

// MARK: - Color Assets Configuration Guide
/*
 Create these colors in your Assets.xcassets with the following hex values:
 
 Light Mode / Dark Mode
 
 PRIMARY COLORS:
 - Primary: #1E88E5 / #42A5F5
 - PrimaryLight: #E3F2FD / #1565C0
 - PrimaryDark: #1565C0 / #0D47A1
 
 SECONDARY COLORS:
 - Secondary: #00897B / #26A69A
 - SecondaryLight: #E0F2F1 / #00695C
 - SecondaryDark: #00695C / #004D40
 
 ACCENT:
 - Accent: #FFA726 / #FFB74D
 
 SEMANTIC COLORS:
 - Profit: #4CAF50 / #66BB6A
 - Loss: #F44336 / #EF5350
 - Neutral: #9E9E9E / #BDBDBD
 
 BACKGROUNDS:
 - Background: #FFFFFF / #121212
 - SecondaryBackground: #F5F5F5 / #1E1E1E
 - TertiaryBackground: #FAFAFA / #2C2C2C
 
 CARDS:
 - CardBackground: #FFFFFF / #1E1E1E
 - ElevatedCard: #FFFFFF / #2C2C2C
 
 TEXT:
 - PrimaryText: #212121 / #FFFFFF
 - SecondaryText: #757575 / #B0B0B0
 - TertiaryText: #9E9E9E / #808080
 
 BORDERS:
 - Border: #E0E0E0 / #424242
 - Divider: #EEEEEE / #333333
 
 CHARTS:
 - Chart1: #1E88E5 / #42A5F5
 - Chart2: #00897B / #26A69A
 - Chart3: #FFA726 / #FFB74D
 - Chart4: #AB47BC / #BA68C8
 - Chart5: #EF5350 / #E57373
 */

// MARK: - Usage Example
struct ThemeExampleView: View {
  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.Spacing.lg) {
        // Balance Card
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
          Text("Total Balance")
            .font(AppTheme.Typography.caption)
            .foregroundColor(AppTheme.Colors.secondaryText)
          
          Text("$24,589.32")
            .font(AppTheme.Typography.financialLarge)
            .foregroundColor(AppTheme.Colors.primaryText)
          
          HStack {
            Image(systemName: "arrow.up.right")
            Text("+$1,234.56 (5.3%)")
              .font(AppTheme.Typography.bodyBold)
          }
          .foregroundColor(AppTheme.Colors.profit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(color: AppTheme.Shadows.card, radius: 8, y: 4)
        
        // Transaction Item
        HStack {
          Circle()
            .fill(AppTheme.Colors.primaryLight)
            .frame(width: 48, height: 48)
            .overlay(
              Image(systemName: "cart.fill")
                .foregroundColor(AppTheme.Colors.primary)
            )
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Amazon Purchase")
              .font(AppTheme.Typography.bodyBold)
              .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Today, 2:34 PM")
              .font(AppTheme.Typography.caption)
              .foregroundColor(AppTheme.Colors.tertiaryText)
          }
          
          Spacer()
          
          Text("-$89.99")
            .font(AppTheme.Typography.financialSmall)
            .foregroundColor(AppTheme.Colors.loss)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        
        // Action Button
        Button(action: {}) {
          Text("View All Transactions")
            .font(AppTheme.Typography.bodyBold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
      }
      .padding(AppTheme.Spacing.lg)
    }
    .background(AppTheme.Colors.background)
  }
}

// MARK: - Preview
//struct ThemeExampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ThemeExampleView()
//                .preferredColorScheme(.light)
//                .previewDisplayName("Light Mode")
//
//            ThemeExampleView()
//                .preferredColorScheme(.dark)
//                .previewDisplayName("Dark Mode")
//        }
//    }
//}

// MARK: - Complete Financial App Examples

struct FinancialDashboardView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: AppTheme.Spacing.lg) {
          // Balance Card
          BalanceCard(
            title: "Total Balance",
            amount: 24589.32,
            change: 1234.56,
            percentage: 5.3,
            isPositive: true
          )
          
          // Quick Actions
          QuickActionsView()
          
          // Recent Transactions
          VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Recent Transactions")
              .font(AppTheme.Typography.title3)
              .foregroundColor(AppTheme.Colors.primaryText)
            
            TransactionRow(
              icon: "cart.fill",
              title: "Amazon",
              subtitle: "Today, 2:34 PM",
              amount: -89.99
            )
            
            TransactionRow(
              icon: "cup.and.saucer.fill",
              title: "Starbucks",
              subtitle: "Today, 9:15 AM",
              amount: -5.75
            )
            
            TransactionRow(
              icon: "arrow.down.circle.fill",
              title: "Salary Deposit",
              subtitle: "Yesterday",
              amount: 3500.00
            )
            
            TransactionRow(
              icon: "bolt.fill",
              title: "Electric Bill",
              subtitle: "2 days ago",
              amount: -125.50
            )
          }
          
          // Spending Summary
          SpendingSummaryCard()
        }
        .padding(AppTheme.Spacing.lg)
      }
      .background(AppTheme.Colors.background)
      .navigationTitle("Dashboard")
    }
  }
}

// MARK: - Balance Card Component
struct BalanceCard: View {
  let title: String
  let amount: Double
  let change: Double
  let percentage: Double
  let isPositive: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text(title)
        .font(AppTheme.Typography.caption)
        .foregroundColor(AppTheme.Colors.secondaryText)
        .textCase(.uppercase)
        .tracking(0.5)
      
      Text(formatCurrency(amount))
        .font(AppTheme.Typography.financialLarge)
        .foregroundColor(AppTheme.Colors.primaryText)
      
      HStack(spacing: AppTheme.Spacing.xs) {
        Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
          .font(.system(size: 14, weight: .bold))
        
        Text("\(formatCurrency(abs(change))) (\(String(format: "%.1f", percentage))%)")
          .font(AppTheme.Typography.bodyBold)
      }
      .foregroundColor(isPositive ? AppTheme.Colors.profit : AppTheme.Colors.loss)
      
      // Mini Chart/Graph Area
      HStack(spacing: 2) {
        ForEach(0..<12) { index in
          Rectangle()
            .fill(AppTheme.Colors.primary.opacity(0.3 + Double(index) * 0.05))
            .frame(height: CGFloat.random(in: 20...60))
        }
      }
      .frame(height: 60)
      .padding(.top, AppTheme.Spacing.sm)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(AppTheme.Spacing.lg)
    .background(
      LinearGradient(
        colors: [
          AppTheme.Colors.primary.opacity(0.1),
          AppTheme.Colors.cardBackground
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .cornerRadius(AppTheme.CornerRadius.large)
    .shadow(color: AppTheme.Shadows.card, radius: 8, y: 4)
  }
  
  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
  }
}

// MARK: - Quick Actions Component
struct QuickActionsView: View {
  var body: some View {
    HStack(spacing: AppTheme.Spacing.md) {
      QuickActionButton(
        icon: "arrow.up.circle.fill",
        title: "Send",
        color: AppTheme.Colors.primary
      )
      
      QuickActionButton(
        icon: "arrow.down.circle.fill",
        title: "Request",
        color: AppTheme.Colors.secondary
      )
      
      QuickActionButton(
        icon: "creditcard.fill",
        title: "Cards",
        color: AppTheme.Colors.accent
      )
      
      QuickActionButton(
        icon: "chart.bar.fill",
        title: "Analytics",
        color: AppTheme.Colors.primaryDark
      )
    }
  }
}

struct QuickActionButton: View {
  let icon: String
  let title: String
  let color: Color
  
  var body: some View {
    VStack(spacing: AppTheme.Spacing.sm) {
      Circle()
        .fill(color.opacity(0.15))
        .frame(width: 56, height: 56)
        .overlay(
          Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundColor(color)
        )
      
      Text(title)
        .font(AppTheme.Typography.caption)
        .foregroundColor(AppTheme.Colors.secondaryText)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Transaction Row Component
struct TransactionRow: View {
  let icon: String
  let title: String
  let subtitle: String
  let amount: Double
  
  var body: some View {
    HStack(spacing: AppTheme.Spacing.md) {
      // Icon
      Circle()
        .fill(AppTheme.Colors.secondaryBackground)
        .frame(width: 48, height: 48)
        .overlay(
          Image(systemName: icon)
            .foregroundColor(amount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.primary)
        )
      
      // Title & Subtitle
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(AppTheme.Typography.bodyBold)
          .foregroundColor(AppTheme.Colors.primaryText)
        
        Text(subtitle)
          .font(AppTheme.Typography.caption)
          .foregroundColor(AppTheme.Colors.tertiaryText)
      }
      
      Spacer()
      
      // Amount
      Text(formatCurrency(amount))
        .font(AppTheme.Typography.financialSmall)
        .foregroundColor(amount >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.primaryText)
    }
    .padding(AppTheme.Spacing.md)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.medium)
  }
  
  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.positivePrefix = "+"
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
  }
}

// MARK: - Spending Summary Card
struct SpendingSummaryCard: View {
  let categories = [
    ("Shopping", 450.00, AppTheme.Colors.chartColors[0]),
    ("Food", 320.50, AppTheme.Colors.chartColors[1]),
    ("Transport", 180.00, AppTheme.Colors.chartColors[2]),
    ("Bills", 625.00, AppTheme.Colors.chartColors[3]),
    ("Other", 125.50, AppTheme.Colors.chartColors[4])
  ]
  
  var total: Double {
    categories.reduce(0) { $0 + $1.1 }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
      Text("Spending by Category")
        .font(AppTheme.Typography.title3)
        .foregroundColor(AppTheme.Colors.primaryText)
      
      // Category bars
      ForEach(categories, id: \.0) { category in
        VStack(spacing: AppTheme.Spacing.xs) {
          HStack {
            Text(category.0)
              .font(AppTheme.Typography.footnote)
              .foregroundColor(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(formatCurrency(category.1))
              .font(AppTheme.Typography.financialSmall)
              .foregroundColor(AppTheme.Colors.primaryText)
          }
          
          GeometryReader { geometry in
            ZStack(alignment: .leading) {
              Rectangle()
                .fill(AppTheme.Colors.tertiaryBackground)
                .frame(height: 8)
                .cornerRadius(4)
              
              Rectangle()
                .fill(category.2)
                .frame(width: geometry.size.width * (category.1 / total), height: 8)
                .cornerRadius(4)
            }
          }
          .frame(height: 8)
        }
      }
      
      Divider()
        .background(AppTheme.Colors.divider)
        .padding(.vertical, AppTheme.Spacing.sm)
      
      HStack {
        Text("Total Spending")
          .font(AppTheme.Typography.bodyBold)
          .foregroundColor(AppTheme.Colors.primaryText)
        
        Spacer()
        
        Text(formatCurrency(total))
          .font(AppTheme.Typography.financialMedium)
          .foregroundColor(AppTheme.Colors.primaryText)
      }
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.cardBackground)
    .cornerRadius(AppTheme.CornerRadius.large)
    .shadow(color: AppTheme.Shadows.card, radius: 8, y: 4)
  }
  
  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
  }
}

// MARK: - Alternate Theme with System Colors
struct SystemColorsExample: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Using system colors
        VStack(alignment: .leading, spacing: 12) {
          Text("Account Balance")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text("$24,589.32")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(.primary)
          
          HStack {
            Image(systemName: "arrow.up.right")
            Text("+5.3%")
              .font(.headline)
          }
          .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        
        // System color palette showcase
        VStack(spacing: 8) {
          ColorSwatch(color: .systemBlue, name: "System Blue")
          ColorSwatch(color: .systemGreen, name: "System Green")
          ColorSwatch(color: .systemOrange, name: "System Orange")
          ColorSwatch(color: .systemRed, name: "System Red")
          ColorSwatch(color: .systemTeal, name: "System Teal")
          ColorSwatch(color: .systemPurple, name: "System Purple")
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground))
  }
}

struct ColorSwatch: View {
  let color: UIColor
  let name: String
  
  var body: some View {
    HStack {
      Circle()
        .fill(Color(color))
        .frame(width: 40, height: 40)
      
      Text(name)
        .font(.body)
      
      Spacer()
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(8)
  }
}

// MARK: - Preview
struct FinancialComponents_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      FinancialDashboardView()
        .preferredColorScheme(.light)
        .previewDisplayName("Custom Theme - Light")
      
      FinancialDashboardView()
        .preferredColorScheme(.dark)
        .previewDisplayName("Custom Theme - Dark")
      
      SystemColorsExample()
        .preferredColorScheme(.light)
        .previewDisplayName("System Colors - Light")
      
      SystemColorsExample()
        .preferredColorScheme(.dark)
        .previewDisplayName("System Colors - Dark")
    }
  }
}
