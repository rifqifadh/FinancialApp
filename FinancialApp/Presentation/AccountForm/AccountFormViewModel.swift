//
//  AddAccountViewModel.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 21/10/25.
//

import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class AccountFormViewModel {
  @ObservationIgnored
  @Dependency(\.accountService) var accountService

  // MARK: - Form Fields
  var name: String = ""
  var selectedCategory: AccountCategory = .bank
  var accountNumber: String = ""
  var currency: String = "IDR"
  var initialBalance: Double = 0
  var balance: Double = 0

  // MARK: - State
  var isSaving = false
  var errorMessage: String?
  var showError = false

  // MARK: - Validation
  var validationErrors: [String] {
    var errors: [String] = []

    if name.trimmingCharacters(in: .whitespaces).isEmpty {
      errors.append("Account name is required")
    }

    if name.count > 50 {
      errors.append("Account name must be less than 50 characters")
    }

    return errors
  }

  var isValid: Bool {
    validationErrors.isEmpty
  }

  // MARK: - Available Options
  let availableCurrencies = ["IDR", "USD", "EUR", "SGD", "MYR"]

  // MARK: - Initialization
  init() {}

  init(account: AccountModel) {
    self.name = account.name
    self.selectedCategory = account.category
    self.accountNumber = account.accountNumber ?? ""
    self.currency = account.currency
    self.initialBalance = account.initialBalance
    self.balance = account.finalBalance
  }

  // MARK: - Actions
  func saveAccount() async -> Bool {
    guard isValid else { return false }

    isSaving = true
    defer { isSaving = false }

    do {
      let params = CreateAccountParams(
        name: name.trimmingCharacters(in: .whitespaces),
        category: selectedCategory.rawValue,
        currency: currency,
        accountNumber: accountNumber.isEmpty ? "" : accountNumber,
        initialBalance: initialBalance,
        finalBalance: initialBalance
      )

      _ = try await accountService.create(params)
      return true
    } catch {
      errorMessage = "Failed to save account: \(error.localizedDescription)"
      showError = true
      return false
    }
  }

  func updateAccount(id: String) async -> Bool {
    guard isValid else { return false }

    isSaving = true
    defer { isSaving = false }

    do {
      let params = UpdateAccountParams(
        id: id,
        name: name.trimmingCharacters(in: .whitespaces),
        category: selectedCategory.rawValue,
        currency: currency,
        accountNumber: accountNumber.isEmpty ? "" : accountNumber,
        finalBalance: balance
      )

      _ = try await accountService.update(id, params)
      return true
    } catch {
      errorMessage = "Failed to update account: \(error.localizedDescription)"
      showError = true
      return false
    }
  }

  func reset() {
    name = ""
    selectedCategory = .bank
    accountNumber = ""
    currency = "IDR"
    initialBalance = 0
    errorMessage = nil
    showError = false
  }
}
