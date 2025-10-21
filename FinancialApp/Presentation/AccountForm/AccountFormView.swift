//
//  AddAccountView.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import SwiftUI

// MARK: - Add Account Mode
enum AddAccountMode: Equatable {
  case add
  case edit(AccountModel)

  var title: String {
    switch self {
    case .add:
      return "Add Account"
    case .edit:
      return "Edit Account"
    }
  }

  var saveButtonTitle: String {
    switch self {
    case .add:
      return "Add Account"
    case .edit:
      return "Save Changes"
    }
  }

  var account: AccountModel? {
    switch self {
    case .add:
      return nil
    case .edit(let account):
      return account
    }
  }
}

struct AddAccountView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: AddAccountViewModel
  let mode: AddAccountMode
  let onSave: (() -> Void)?

  init(mode: AddAccountMode = .add, onSave: (() -> Void)? = nil) {
    self.mode = mode
    self.onSave = onSave

    // Initialize view model based on mode
    switch mode {
    case .add:
      _viewModel = State(initialValue: AddAccountViewModel())
    case .edit(let account):
      _viewModel = State(initialValue: AddAccountViewModel(account: account))
    }
  }

  var body: some View {
    NavigationStack {
      Form {
        // MARK: - Account Details Section
        Section {
          // Account Name
          VStack(alignment: .leading, spacing: 8) {
            Text("Account Name")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField("e.g., My Savings", text: $viewModel.name)
              .textFieldStyle(.plain)
              .font(AppTheme.Typography.body)
          }
          .padding(.vertical, 4)

          // Category
          VStack(alignment: .leading, spacing: 8) {
            Text("Category")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            Picker("Category", selection: $viewModel.selectedCategory) {
              ForEach(AccountCategory.allCases, id: \.self) { category in
                HStack {
                  Image(systemName: category.icon)
                  Text(category.displayName)
                }
                .tag(category)
              }
            }
            .pickerStyle(.menu)
          }
          .padding(.vertical, 4)

          // Account Number (Optional)
          VStack(alignment: .leading, spacing: 8) {
            Text("Account Number (Optional)")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField("e.g., 1234567890", text: $viewModel.accountNumber)
              .textFieldStyle(.plain)
              .font(AppTheme.Typography.body)
              .keyboardType(.numberPad)
          }
          .padding(.vertical, 4)
        } header: {
          Text("Account Details")
        }

        // MARK: - Financial Section
        Section {
          // Currency
          VStack(alignment: .leading, spacing: 8) {
            Text("Currency")
              .font(AppTheme.Typography.caption)
              .foregroundStyle(AppTheme.Colors.secondaryText)

            Picker("Currency", selection: $viewModel.currency) {
              ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                Text(currency)
                  .tag(currency)
              }
            }
            .pickerStyle(.menu)
          }
          .padding(.vertical, 4)

          // Initial Balance (only for add mode)
          if case .add = mode {
            VStack(alignment: .leading, spacing: 8) {
              Text("Initial Balance")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

              HStack {
                Text(viewModel.currency)
                  .font(AppTheme.Typography.body)
                  .foregroundStyle(AppTheme.Colors.secondaryText)

                TextField("0", value: $viewModel.initialBalance, format: .number)
                  .textFieldStyle(.plain)
                  .font(AppTheme.Typography.body)
                  .keyboardType(.numberPad)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("Financial Information")
        }

        // MARK: - Validation Errors
        if !viewModel.validationErrors.isEmpty {
          Section {
            ForEach(viewModel.validationErrors, id: \.self) { error in
              HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                  .foregroundStyle(.red)
                Text(error)
                  .font(AppTheme.Typography.caption)
                  .foregroundStyle(.red)
              }
            }
          }
        }
      }
      .navigationTitle(mode.title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(mode.saveButtonTitle) {
            Task {
              await saveAccount()
            }
          }
          .disabled(!viewModel.isValid || viewModel.isSaving)
        }
      }
      .overlay {
        if viewModel.isSaving {
          LoadingView(label: "Saving account...")
        }
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK", role: .cancel) {}
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
    }
  }

  // MARK: - Actions
  private func saveAccount() async {
    let success: Bool

    switch mode {
    case .add:
      success = await viewModel.saveAccount()
    case .edit(let account):
      success = await viewModel.updateAccount(id: account.id)
    }

    if success {
      onSave?()
      dismiss()
    }
  }
}

#Preview("Add Account") {
  AddAccountView(mode: .add)
}

#Preview("Edit Account") {
  AddAccountView(mode: .edit(.mockBank))
}
