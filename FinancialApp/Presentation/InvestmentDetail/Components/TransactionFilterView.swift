//
//  TransactionFilterView.swift
//  FinancialApp
//
//  Created by Claude on 11/12/25.
//

import SwiftUI

enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case buy = "Buy"
    case sell = "Sell"
    case dividend = "Dividend"

    var icon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .buy:
            return "arrow.down.circle.fill"
        case .sell:
            return "arrow.up.circle.fill"
        case .dividend:
            return "dollarsign.circle.fill"
        }
    }

    func matches(_ transaction: InvestmentTransactionModel) -> Bool {
        switch self {
        case .all:
            return true
        case .buy:
            return transaction.type == .buy
        case .sell:
            return transaction.type == .sell
        case .dividend:
            return transaction.type == .dividend
        }
    }
}

enum TransactionSortOption: String, CaseIterable {
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
    case amountHighest = "Highest Amount"
    case amountLowest = "Lowest Amount"

    var icon: String {
        switch self {
        case .dateNewest:
            return "calendar.badge.clock"
        case .dateOldest:
            return "calendar"
        case .amountHighest:
            return "arrow.up.arrow.down"
        case .amountLowest:
            return "arrow.down.arrow.up"
        }
    }
}

struct TransactionFilterView: View {
    @Binding var selectedFilter: TransactionFilter
    @Binding var selectedSort: TransactionSortOption
    @Binding var searchText: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.Colors.tertiaryText)

                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                    }
                }
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.small)

            // Filter & Sort
            HStack(spacing: AppTheme.Spacing.sm) {
                // Filter Picker
                Menu {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Button {
                            withAnimation {
                                selectedFilter = filter
                            }
                        } label: {
                            Label(filter.rawValue, systemImage: filter.icon)
                        }
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: selectedFilter.icon)
                        Text(selectedFilter.rawValue)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }

                // Sort Picker
                Menu {
                    ForEach(TransactionSortOption.allCases, id: \.self) { option in
                        Button {
                            withAnimation {
                                selectedSort = option
                            }
                        } label: {
                            Label(option.rawValue, systemImage: option.icon)
                        }
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: selectedSort.icon)
                        Text("Sort")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }

                Spacer()

                // Active filters indicator
                if selectedFilter != .all || !searchText.isEmpty {
                    Button {
                        withAnimation {
                            selectedFilter = .all
                            searchText = ""
                        }
                    } label: {
                        Text("Clear")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionFilterView(
        selectedFilter: .constant(.all),
        selectedSort: .constant(.dateNewest),
        searchText: .constant("")
    )
    .padding()
}
