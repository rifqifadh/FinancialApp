//
//  Account.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


import SwiftUI

// MARK: - Account Model
struct Account: Identifiable {
    let id = UUID()
    let name: String
    let type: AccountType
    let balance: Double
    let accountNumber: String
    let icon: String
    let color: Color
}

enum AccountType {
    case checking
    case savings
    case credit
    case investment
    
    var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .credit: return "Credit Card"
        case .investment: return "Investment"
        }
    }
}

// MARK: - Accounts View
struct AccountsView: View {
    @State private var accounts: [Account] = [
        Account(
            name: "Main Checking",
            type: .checking,
            balance: 12458.67,
            accountNumber: "****4521",
            icon: "banknote.fill",
            color: AppThemeV2.Colors.primary
        ),
        Account(
            name: "High-Yield Savings",
            type: .savings,
            balance: 45890.23,
            accountNumber: "****7832",
            icon: "building.columns.fill",
            color: AppThemeV2.Colors.secondary
        ),
        Account(
            name: "Visa Platinum",
            type: .credit,
            balance: -2347.82,
            accountNumber: "****3941",
            icon: "creditcard.fill",
            color: AppThemeV2.Colors.accent
        ),
        Account(
            name: "Investment Portfolio",
            type: .investment,
            balance: 128450.50,
            accountNumber: "****6128",
            icon: "chart.line.uptrend.xyaxis",
            color: Color(red: 0.67, green: 0.28, blue: 0.74) // Purple
        )
    ]
    
    @State private var showAddAccount = false
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppThemeV2.Spacing.lg) {
                    // Total Net Worth Card
                    TotalBalanceCard(totalBalance: totalBalance)
                    
                    // Accounts Section
                    VStack(alignment: .leading, spacing: AppThemeV2.Spacing.md) {
                        HStack {
                            Text("My Accounts")
                                .font(AppThemeV2.Typography.title3)
                                .foregroundColor(AppThemeV2.Colors.primaryText)
                            
                            Spacer()
                            
                            Text("\(accounts.count) accounts")
                                .font(AppThemeV2.Typography.caption)
                                .foregroundColor(AppThemeV2.Colors.secondaryText)
                        }
                        
                        ForEach(accounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account)) {
                                AccountCard(account: account)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Add Account Button
                    Button(action: { showAddAccount = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("Add New Account")
                                .font(AppThemeV2.Typography.bodyBold)
                        }
                        .foregroundColor(AppThemeV2.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(AppThemeV2.Spacing.md)
                        .background(AppThemeV2.Colors.primaryLight)
                        .cornerRadius(AppThemeV2.CornerRadius.medium)
                    }
                }
                .padding(AppThemeV2.Spacing.lg)
            }
            .background(AppThemeV2.Colors.background)
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddAccount) {
                AddAccountSheet(isPresented: $showAddAccount)
            }
        }
    }
}

// MARK: - Total Balance Card
struct TotalBalanceCard: View {
    let totalBalance: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppThemeV2.Spacing.md) {
            Text("Total Net Worth")
                .font(AppThemeV2.Typography.caption)
                .foregroundColor(AppThemeV2.Colors.secondaryText)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(formatCurrency(totalBalance))
                .font(AppThemeV2.Typography.financialLarge)
                .foregroundColor(AppThemeV2.Colors.primaryText)
            
            HStack(spacing: AppThemeV2.Spacing.sm) {
                // Assets
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assets")
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                    Text("$186,799.40")
                        .font(AppThemeV2.Typography.bodyBold)
                        .foregroundColor(AppThemeV2.Colors.profit)
                }
                
                Divider()
                    .frame(height: 30)
                    .background(AppThemeV2.Colors.divider)
                
                // Liabilities
                VStack(alignment: .leading, spacing: 4) {
                    Text("Liabilities")
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                    Text("$2,347.82")
                        .font(AppThemeV2.Typography.bodyBold)
                        .foregroundColor(AppThemeV2.Colors.loss)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppThemeV2.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppThemeV2.Colors.secondary.opacity(0.1),
                    AppThemeV2.Colors.cardBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppThemeV2.CornerRadius.large)
        .shadow(color: AppThemeV2.Shadows.card, radius: 8, y: 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Account Card
struct AccountCard: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: AppThemeV2.Spacing.md) {
            // Icon
            Circle()
                .fill(account.color.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: account.icon)
                        .font(.system(size: 24))
                        .foregroundColor(account.color)
                )
            
            // Account Info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(AppThemeV2.Typography.bodyBold)
                    .foregroundColor(AppThemeV2.Colors.primaryText)
                
                HStack(spacing: 6) {
                    Text(account.type.displayName)
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.secondaryText)
                    
                    Text("•")
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                    
                    Text(account.accountNumber)
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Balance
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(abs(account.balance)))
                    .font(AppThemeV2.Typography.financialSmall)
                    .foregroundColor(AppThemeV2.Colors.primaryText)
                
                if account.balance < 0 {
                    Text("Balance Due")
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.loss)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppThemeV2.Colors.tertiaryText)
        }
        .padding(AppThemeV2.Spacing.md)
        .background(AppThemeV2.Colors.cardBackground)
        .cornerRadius(AppThemeV2.CornerRadius.medium)
        .shadow(color: AppThemeV2.Shadows.card, radius: 4, y: 2)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Account Detail View
struct AccountDetailView: View {
    let account: Account
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppThemeV2.Spacing.lg) {
                // Account Header
                VStack(spacing: AppThemeV2.Spacing.md) {
                    Circle()
                        .fill(account.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: account.icon)
                                .font(.system(size: 36))
                                .foregroundColor(account.color)
                        )
                    
                    Text(account.name)
                        .font(AppThemeV2.Typography.title2)
                        .foregroundColor(AppThemeV2.Colors.primaryText)
                    
                    Text(account.accountNumber)
                        .font(AppThemeV2.Typography.footnote)
                        .foregroundColor(AppThemeV2.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(AppThemeV2.Spacing.xl)
                .background(AppThemeV2.Colors.cardBackground)
                .cornerRadius(AppThemeV2.CornerRadius.large)
                
                // Balance Card
                VStack(alignment: .leading, spacing: AppThemeV2.Spacing.sm) {
                    Text(account.balance < 0 ? "Current Balance Due" : "Available Balance")
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.secondaryText)
                        .textCase(.uppercase)
                    
                    Text(formatCurrency(abs(account.balance)))
                        .font(AppThemeV2.Typography.financialLarge)
                        .foregroundColor(account.balance < 0 ? AppThemeV2.Colors.loss : AppThemeV2.Colors.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppThemeV2.Spacing.lg)
                .background(AppThemeV2.Colors.cardBackground)
                .cornerRadius(AppThemeV2.CornerRadius.medium)
                
                // Quick Actions
                HStack(spacing: AppThemeV2.Spacing.md) {
                    AccountActionButton(
                        icon: "arrow.up.circle.fill",
                        title: "Transfer",
                        color: AppThemeV2.Colors.primary
                    )
                    
                    AccountActionButton(
                        icon: "arrow.down.circle.fill",
                        title: "Deposit",
                        color: AppThemeV2.Colors.secondary
                    )
                    
                    AccountActionButton(
                        icon: "doc.text.fill",
                        title: "Statement",
                        color: AppThemeV2.Colors.accent
                    )
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: AppThemeV2.Spacing.md) {
                    Text("Recent Activity")
                        .font(AppThemeV2.Typography.title3)
                        .foregroundColor(AppThemeV2.Colors.primaryText)
                    
                    TransactionRow(
                        icon: "cart.fill",
                        title: "Amazon Purchase",
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
                        icon: "fuelpump.fill",
                        title: "Shell Gas Station",
                        subtitle: "Yesterday",
                        amount: -52.30
                    )
                }
            }
            .padding(AppThemeV2.Spacing.lg)
        }
        .background(AppThemeV2.Colors.background)
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Account Action Button
struct AccountActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: AppThemeV2.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppThemeV2.Typography.caption)
                    .foregroundColor(AppThemeV2.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(AppThemeV2.Spacing.md)
            .background(AppThemeV2.Colors.cardBackground)
            .cornerRadius(AppThemeV2.CornerRadius.medium)
        }
    }
}

// MARK: - Add Account Sheet
struct AddAccountSheet: View {
    @Binding var isPresented: Bool
    @State private var accountName = ""
    @State private var selectedType: AccountType = .checking
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Account Name", text: $accountName)
                    
                    Picker("Account Type", selection: $selectedType) {
                        Text("Checking").tag(AccountType.checking)
                        Text("Savings").tag(AccountType.savings)
                        Text("Credit Card").tag(AccountType.credit)
                        Text("Investment").tag(AccountType.investment)
                    }
                }
                
                Section {
                    Button("Add Account") {
                        // Add account logic
                        isPresented = false
                    }
                    .disabled(accountName.isEmpty)
                }
            }
            .navigationTitle("Add New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountsView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            AccountsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
