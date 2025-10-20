//
//  TransactionFilterSheet.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 20/10/25.
//

import SwiftUI

struct TransactionFilterSheet: View {
  // MARK: - Bindings
  @Binding var selectedMonth: Date
  @Binding var selectedType: TransactionType?
  @Binding var selectedCategoryId: Int?
  @Binding var isPresented: Bool

  // MARK: - Properties
  let availableCategories: [TransactionCategory]

  // MARK: - Body
  var body: some View {
    NavigationView {
      List {
        // Month Section
        Section("Month") {
          ForEach(-6..<1) { monthOffset in
            let date = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
            Button(action: {
              selectedMonth = date
              isPresented = false
            }) {
              HStack {
                Text(date.formatted("MMMM yyyy"))
                  .foregroundColor(AppTheme.Colors.primaryText)
                Spacer()
                if Calendar.current.isDate(date, equalTo: selectedMonth, toGranularity: .month) {
                  Image(systemName: "checkmark")
                    .foregroundColor(AppTheme.Colors.primary)
                }
              }
            }
          }
        }

        // Transaction Type Section
        Section("Transaction Type") {
          Button(action: {
            selectedType = nil
            isPresented = false
          }) {
            HStack {
              Image(systemName: "list.bullet")
              Text("All Types")
                .foregroundColor(AppTheme.Colors.primaryText)
              Spacer()
              if selectedType == nil {
                Image(systemName: "checkmark")
                  .foregroundColor(AppTheme.Colors.primary)
              }
            }
          }

          ForEach([TransactionType.expense, .income, .transfer, .split_bill], id: \.self) { type in
            Button(action: {
              selectedType = type
              isPresented = false
            }) {
              HStack {
                Image(systemName: type.icon)
                Text(type.label)
                  .foregroundColor(AppTheme.Colors.primaryText)
                Spacer()
                if selectedType == type {
                  Image(systemName: "checkmark")
                    .foregroundColor(AppTheme.Colors.primary)
                }
              }
            }
          }
        }

        // Category Section
        Section("Category") {
          Button(action: {
            selectedCategoryId = nil
            isPresented = false
          }) {
            HStack {
              Text("All Categories")
                .foregroundColor(AppTheme.Colors.primaryText)
              Spacer()
              if selectedCategoryId == nil {
                Image(systemName: "checkmark")
                  .foregroundColor(AppTheme.Colors.primary)
              }
            }
          }

          ForEach(availableCategories, id: \.id) { category in
            Button(action: {
              selectedCategoryId = category.id
              isPresented = false
            }) {
              HStack {
                Image(systemName: category.iconName)
                Text(category.name)
                  .foregroundColor(AppTheme.Colors.primaryText)
                Spacer()
                if selectedCategoryId == category.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(AppTheme.Colors.primary)
                }
              }
            }
          }
        }
      }
      .navigationTitle("Filters")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Reset") {
            selectedType = nil
            selectedCategoryId = nil
            selectedMonth = Date()
          }
          .foregroundColor(AppTheme.Colors.loss)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            isPresented = false
          }
          .foregroundColor(AppTheme.Colors.primary)
        }
      }
    }
    .presentationDetents([.medium, .large])
  }
}

// MARK: - Preview
#Preview("Filter Sheet") {
  TransactionFilterSheet(
    selectedMonth: .constant(Date()),
    selectedType: .constant(nil),
    selectedCategoryId: .constant(nil),
    isPresented: .constant(true),
    availableCategories: [
      TransactionCategory(id: 1, iconName: "fork.knife", name: "Food & Dining"),
      TransactionCategory(id: 2, iconName: "cart.fill", name: "Shopping"),
      TransactionCategory(id: 3, iconName: "car.fill", name: "Transportation"),
      TransactionCategory(id: 4, iconName: "house.fill", name: "Housing"),
      TransactionCategory(id: 5, iconName: "film.fill", name: "Entertainment")
    ]
  )
}

#Preview("With Selections") {
  TransactionFilterSheet(
    selectedMonth: .constant(Date()),
    selectedType: .constant(.expense),
    selectedCategoryId: .constant(1),
    isPresented: .constant(true),
    availableCategories: [
      TransactionCategory(id: 1, iconName: "fork.knife", name: "Food & Dining"),
      TransactionCategory(id: 2, iconName: "cart.fill", name: "Shopping"),
      TransactionCategory(id: 3, iconName: "car.fill", name: "Transportation")
    ]
  )
}
