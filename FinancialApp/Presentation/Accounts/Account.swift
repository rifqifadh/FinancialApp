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
            color: AppTheme.Colors.primary
        ),
        Account(
            name: "High-Yield Savings",
            type: .savings,
            balance: 45890.23,
            accountNumber: "****7832",
            icon: "building.columns.fill",
            color: AppTheme.Colors.secondary
        ),
        Account(
            name: "Visa Platinum",
            type: .credit,
            balance: -2347.82,
            accountNumber: "****3941",
            icon: "creditcard.fill",
            color: AppTheme.Colors.accent
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
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Total Net Worth Card
                    TotalBalanceCard(totalBalance: totalBalance)
                    
                    // Accounts Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text("My Accounts")
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            Spacer()
                            
                            Text("\(accounts.count) accounts")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
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
                                .font(AppTheme.Typography.bodyBold)
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.primaryLight)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Total Net Worth")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(formatCurrency(totalBalance))
                .font(AppTheme.Typography.financialLarge)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: AppTheme.Spacing.sm) {
                // Assets
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assets")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text("$186,799.40")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.Colors.profit)
                }
                
                Divider()
                    .frame(height: 30)
                    .background(AppTheme.Colors.divider)
                
                // Liabilities
                VStack(alignment: .leading, spacing: 4) {
                    Text("Liabilities")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text("$2,347.82")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.Colors.loss)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.secondary.opacity(0.1),
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

// MARK: - Account Card
struct AccountCard: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
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
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                HStack(spacing: 6) {
                    Text(account.type.displayName)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("•")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    
                    Text(account.accountNumber)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Balance
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(abs(account.balance)))
                    .font(AppTheme.Typography.financialSmall)
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                if account.balance < 0 {
                    Text("Balance Due")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.loss)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: AppTheme.Shadows.card, radius: 4, y: 2)
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
            VStack(spacing: AppTheme.Spacing.lg) {
                // Account Header
                VStack(spacing: AppTheme.Spacing.md) {
                    Circle()
                        .fill(account.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: account.icon)
                                .font(.system(size: 36))
                                .foregroundColor(account.color)
                        )
                    
                    Text(account.name)
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    Text(account.accountNumber)
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.xl)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)
                
                // Balance Card
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(account.balance < 0 ? "Current Balance Due" : "Available Balance")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .textCase(.uppercase)
                    
                    Text(formatCurrency(abs(account.balance)))
                        .font(AppTheme.Typography.financialLarge)
                        .foregroundColor(account.balance < 0 ? AppTheme.Colors.loss : AppTheme.Colors.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                
                // Quick Actions
                HStack(spacing: AppTheme.Spacing.md) {
                    AccountActionButton(
                        icon: "arrow.up.circle.fill",
                        title: "Transfer",
                        color: AppTheme.Colors.primary
                    )
                    
                    AccountActionButton(
                        icon: "arrow.down.circle.fill",
                        title: "Deposit",
                        color: AppTheme.Colors.secondary
                    )
                    
                    AccountActionButton(
                        icon: "doc.text.fill",
                        title: "Statement",
                        color: AppTheme.Colors.accent
                    )
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Recent Activity")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
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
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
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
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
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
