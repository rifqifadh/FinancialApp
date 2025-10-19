//
//  TransactionModel.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


import SwiftUI

// MARK: - TransactionModel Model
struct TransactionModel: Identifiable {
    let id = UUID()
    let title: String
    let category: TransactionCategory
    let amount: Double
    let date: Date
    let account: String
    let icon: String
    let note: String?
    
    var isExpense: Bool {
        amount < 0
    }
}

enum TransactionCategory: String, CaseIterable {
    case shopping = "Shopping"
    case food = "Food & Dining"
    case transport = "Transport"
    case bills = "Bills & Utilities"
    case entertainment = "Entertainment"
    case health = "Health"
    case income = "Income"
    case transfer = "Transfer"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .shopping: return "cart.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .bills: return "bolt.fill"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .income: return "arrow.down.circle.fill"
        case .transfer: return "arrow.left.arrow.right"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .shopping: return AppThemeV2.Colors.primary
        case .food: return AppThemeV2.Colors.accent
        case .transport: return AppThemeV2.Colors.secondary
        case .bills: return Color(red: 0.95, green: 0.42, blue: 0.42)
        case .entertainment: return Color(red: 0.67, green: 0.28, blue: 0.74)
        case .health: return Color(red: 0.91, green: 0.30, blue: 0.24)
        case .income: return AppThemeV2.Colors.profit
        case .transfer: return AppThemeV2.Colors.neutral
        case .other: return AppThemeV2.Colors.primaryDark
        }
    }
}

// MARK: - Transactions View
struct TransactionsView: View {
    @State private var transactions: [TransactionModel] = TransactionData.sampleTransactions
    @State private var searchText = ""
    @State private var selectedCategory: TransactionCategory?
    @State private var showFilterSheet = false
    @State private var selectedTransaction: TransactionModel?
    
    var filteredTransactions: [TransactionModel] {
        var result = transactions
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { TransactionModel in
                TransactionModel.title.localizedCaseInsensitiveContains(searchText) ||
                TransactionModel.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        return result
    }
    
    var groupedTransactions: [(String, [TransactionModel])] {
        let grouped = Dictionary(grouping: filteredTransactions) { TransactionModel in
            TransactionModel.date.formatted(.dateTime.month(.wide).day())
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var totalIncome: Double {
        filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        abs(filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary Cards
                SummaryCardsView(income: totalIncome, expenses: totalExpenses)
                    .padding(.horizontal, AppThemeV2.Spacing.lg)
                    .padding(.top, AppThemeV2.Spacing.md)
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, AppThemeV2.Spacing.lg)
                    .padding(.top, AppThemeV2.Spacing.md)
                
                // Category Filter
                if !TransactionCategory.allCases.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppThemeV2.Spacing.sm) {
                            CategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(TransactionCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedCategory == category,
                                    action: { 
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, AppThemeV2.Spacing.lg)
                    }
                    .padding(.top, AppThemeV2.Spacing.md)
                }
                
                // Transactions List
                ScrollView {
                    LazyVStack(spacing: AppThemeV2.Spacing.lg) {
                        ForEach(groupedTransactions, id: \.0) { dateGroup in
                            VStack(alignment: .leading, spacing: AppThemeV2.Spacing.md) {
                                // Date Header
                                Text(dateGroup.0)
                                    .font(AppThemeV2.Typography.bodyBold)
                                    .foregroundColor(AppThemeV2.Colors.primaryText)
                                    .padding(.horizontal, AppThemeV2.Spacing.lg)
                                
                                // Transactions for this date
                                ForEach(dateGroup.1) { TransactionModel in
                                    TransactionRowView(TransactionModel: TransactionModel)
                                        .padding(.horizontal, AppThemeV2.Spacing.lg)
                                        .onTapGesture {
                                            selectedTransaction = TransactionModel
                                        }
                                }
                            }
                        }
                    }
                    .padding(.top, AppThemeV2.Spacing.lg)
                    .padding(.bottom, AppThemeV2.Spacing.xl)
                }
                .background(AppThemeV2.Colors.background)
            }
            .background(AppThemeV2.Colors.background)
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(AppThemeV2.Colors.primary)
                    }
                }
            }
            .sheet(item: $selectedTransaction) { TransactionModel in
                TransactionDetailSheet(TransactionModel: TransactionModel)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(isPresented: $showFilterSheet)
            }
        }
    }
}

// MARK: - Summary Cards View
struct SummaryCardsView: View {
    let income: Double
    let expenses: Double
    
    var body: some View {
        HStack(spacing: AppThemeV2.Spacing.md) {
            SummaryCard(
                title: "Income",
                amount: income,
                color: AppThemeV2.Colors.profit,
                icon: "arrow.down.circle.fill"
            )
            
            SummaryCard(
                title: "Expenses",
                amount: expenses,
                color: AppThemeV2.Colors.loss,
                icon: "arrow.up.circle.fill"
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppThemeV2.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppThemeV2.Typography.caption)
                    .foregroundColor(AppThemeV2.Colors.secondaryText)
            }
            
            Text(formatCurrency(amount))
                .font(AppThemeV2.Typography.financialMedium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppThemeV2.Spacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(AppThemeV2.CornerRadius.medium)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: AppThemeV2.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppThemeV2.Colors.tertiaryText)
            
            TextField("Search transactions...", text: $text)
                .font(AppThemeV2.Typography.body)
                .foregroundColor(AppThemeV2.Colors.primaryText)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                }
            }
        }
        .padding(AppThemeV2.Spacing.md)
        .background(AppThemeV2.Colors.secondaryBackground)
        .cornerRadius(AppThemeV2.CornerRadius.medium)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = AppThemeV2.Colors.primary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(AppThemeV2.Typography.caption)
            }
            .padding(.horizontal, AppThemeV2.Spacing.md)
            .padding(.vertical, AppThemeV2.Spacing.sm)
            .background(isSelected ? color : AppThemeV2.Colors.secondaryBackground)
            .foregroundColor(isSelected ? .white : AppThemeV2.Colors.secondaryText)
            .cornerRadius(AppThemeV2.CornerRadius.large)
        }
    }
}

// MARK: - TransactionModel Row View
struct TransactionRowView: View {
    let TransactionModel: TransactionModel
    
    var body: some View {
        HStack(spacing: AppThemeV2.Spacing.md) {
            // Icon
            Circle()
                .fill(TransactionModel.category.color.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: TransactionModel.category.icon)
                        .foregroundColor(TransactionModel.category.color)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(TransactionModel.title)
                    .font(AppThemeV2.Typography.bodyBold)
                    .foregroundColor(AppThemeV2.Colors.primaryText)
                
                HStack(spacing: 6) {
                    Text(TransactionModel.category.rawValue)
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.secondaryText)
                    
                    Text("•")
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                    
                    Text(TransactionModel.account)
                        .font(AppThemeV2.Typography.caption)
                        .foregroundColor(AppThemeV2.Colors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(TransactionModel.amount))
                .font(AppThemeV2.Typography.financialSmall)
                .foregroundColor(TransactionModel.isExpense ? AppThemeV2.Colors.primaryText : AppThemeV2.Colors.profit)
        }
        .padding(AppThemeV2.Spacing.md)
        .background(AppThemeV2.Colors.cardBackground)
        .cornerRadius(AppThemeV2.CornerRadius.medium)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - TransactionModel Detail Sheet
struct TransactionDetailSheet: View {
    let TransactionModel: TransactionModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppThemeV2.Spacing.xl) {
                    // Icon and Amount
                    VStack(spacing: AppThemeV2.Spacing.md) {
                        Circle()
                            .fill(TransactionModel.category.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: TransactionModel.category.icon)
                                    .font(.system(size: 36))
                                    .foregroundColor(TransactionModel.category.color)
                            )
                        
                        Text(formatCurrency(TransactionModel.amount))
                            .font(AppThemeV2.Typography.financialLarge)
                            .foregroundColor(TransactionModel.isExpense ? AppThemeV2.Colors.primaryText : AppThemeV2.Colors.profit)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppThemeV2.Spacing.xl)
                    
                    // Details
                    VStack(spacing: AppThemeV2.Spacing.md) {
                        DetailRow(label: "Merchant", value: TransactionModel.title)
                        DetailRow(label: "Category", value: TransactionModel.category.rawValue)
                        DetailRow(label: "Account", value: TransactionModel.account)
                        DetailRow(label: "Date", value: TransactionModel.date.formatted(.dateTime.month().day().year().hour().minute()))
                        
                        if let note = TransactionModel.note {
                            DetailRow(label: "Note", value: note)
                        }
                    }
                    .padding(AppThemeV2.Spacing.lg)
                    .background(AppThemeV2.Colors.cardBackground)
                    .cornerRadius(AppThemeV2.CornerRadius.large)
                    
                    // Action Buttons
                    VStack(spacing: AppThemeV2.Spacing.md) {
                        Button(action: {}) {
                            Text("Edit TransactionModel")
                                .font(AppThemeV2.Typography.bodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(AppThemeV2.Spacing.md)
                                .background(AppThemeV2.Colors.primary)
                                .cornerRadius(AppThemeV2.CornerRadius.medium)
                        }
                        
                        Button(action: {}) {
                            Text("Delete TransactionModel")
                                .font(AppThemeV2.Typography.bodyBold)
                                .foregroundColor(AppThemeV2.Colors.loss)
                                .frame(maxWidth: .infinity)
                                .padding(AppThemeV2.Spacing.md)
                                .background(AppThemeV2.Colors.loss.opacity(0.1))
                                .cornerRadius(AppThemeV2.CornerRadius.medium)
                        }
                    }
                }
                .padding(AppThemeV2.Spacing.lg)
            }
            .background(AppThemeV2.Colors.background)
            .navigationTitle("TransactionModel Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppThemeV2.Typography.body)
                .foregroundColor(AppThemeV2.Colors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(AppThemeV2.Typography.bodyBold)
                .foregroundColor(AppThemeV2.Colors.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Date Range")) {
                    Text("This Month")
                    Text("Last 3 Months")
                    Text("This Year")
                    Text("Custom Range")
                }
                
                Section(header: Text("Amount Range")) {
                    Text("All Amounts")
                    Text("Under $50")
                    Text("$50 - $200")
                    Text("Over $200")
                }
                
                Section(header: Text("TransactionModel Type")) {
                    Text("All Transactions")
                    Text("Income Only")
                    Text("Expenses Only")
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        // Reset filters
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Sample Data
struct TransactionData {
    static var sampleTransactions: [TransactionModel] {
        [
            TransactionModel(title: "Amazon", category: .shopping, amount: -89.99, date: Date(), account: "****4521", icon: "cart.fill", note: "Office supplies"),
            TransactionModel(title: "Starbucks", category: .food, amount: -5.75, date: Date(), account: "****4521", icon: "cup.and.saucer.fill", note: nil),
            TransactionModel(title: "Salary Deposit", category: .income, amount: 3500.00, date: Date().addingTimeInterval(-86400), account: "****4521", icon: "arrow.down.circle.fill", note: "Monthly salary"),
            TransactionModel(title: "Uber", category: .transport, amount: -18.50, date: Date().addingTimeInterval(-86400), account: "****4521", icon: "car.fill", note: nil),
            TransactionModel(title: "Netflix", category: .entertainment, amount: -15.99, date: Date().addingTimeInterval(-172800), account: "****3941", icon: "tv.fill", note: "Monthly subscription"),
            TransactionModel(title: "Electric Bill", category: .bills, amount: -125.50, date: Date().addingTimeInterval(-172800), account: "****4521", icon: "bolt.fill", note: nil),
            TransactionModel(title: "Whole Foods", category: .food, amount: -87.34, date: Date().addingTimeInterval(-259200), account: "****4521", icon: "cart.fill", note: "Groceries"),
            TransactionModel(title: "Gas Station", category: .transport, amount: -45.00, date: Date().addingTimeInterval(-259200), account: "****3941", icon: "fuelpump.fill", note: nil),
            TransactionModel(title: "Gym Membership", category: .health, amount: -49.99, date: Date().addingTimeInterval(-345600), account: "****4521", icon: "heart.fill", note: "Monthly membership"),
            TransactionModel(title: "Freelance Work", category: .income, amount: 850.00, date: Date().addingTimeInterval(-432000), account: "****4521", icon: "arrow.down.circle.fill", note: "Design project"),
            TransactionModel(title: "Target", category: .shopping, amount: -127.89, date: Date().addingTimeInterval(-432000), account: "****3941", icon: "cart.fill", note: nil),
            TransactionModel(title: "Coffee Shop", category: .food, amount: -6.50, date: Date().addingTimeInterval(-518400), account: "****4521", icon: "cup.and.saucer.fill", note: nil),
        ]
    }
}

// MARK: - Preview
struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionsView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            TransactionsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
