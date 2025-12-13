//
//  MaturityBannerView.swift
//  FinancialApp
//
//  Created by Claude on 11/12/25.
//

import SwiftUI
import Dependencies

struct MaturityBannerView: View {
    let investment: InvestmentResponse
    let onUpdateValue: () -> Void

    @State private var showingUpdateSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.Colors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Investment Matured")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(maturityMessage)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }

                Spacer()
            }

            Button {
                showingUpdateSheet = true
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Update Value")
                }
                .font(AppTheme.Typography.bodyBold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.accent)
                .cornerRadius(AppTheme.CornerRadius.small)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.accent.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.accent.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showingUpdateSheet) {
            MaturityUpdateFormView(investment: investment) {
                onUpdateValue()
            }
        }
    }

    private var maturityMessage: String {
        if let maturityDate = investment.maturityDate {
            let daysAgo = Calendar.current.dateComponents([.day], from: maturityDate, to: Date()).day ?? 0
            if daysAgo == 0 {
                return "Matured today"
            } else if daysAgo == 1 {
                return "Matured yesterday"
            } else {
                return "Matured \(daysAgo) days ago"
            }
        }
        return "Please update the current value"
    }
}

// MARK: - Maturity Update Form
struct MaturityUpdateFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.investmentService) var investmentService

    let investment: InvestmentResponse
    var onSave: (() -> Void)?

    @State private var newValue = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false

    var calculatedValue: Int {
        guard let rate = investment.interestRate,
              let maturityDate = investment.maturityDate else {
            return investment.currentValue
        }

        let days = Calendar.current.dateComponents([.day], from: investment.purchaseDate, to: maturityDate).day ?? 0
        let years = Double(days) / 365.0
        let interest = Double(investment.initialAmount) * (rate / 100.0) * years
        return investment.initialAmount + Int(interest)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Current Details") {
                    LabeledContent("Initial Amount", value: investment.initialAmount.toCurrency())
                    LabeledContent("Current Value", value: investment.currentValue.toCurrency())

                    if let rate = investment.interestRate {
                        LabeledContent("Interest Rate", value: "\(String(format: "%.2f", rate))% p.a.")
                    }

                    if let maturityDate = investment.maturityDate {
                        LabeledContent("Maturity Date", value: formatDate(maturityDate))
                    }
                }

                if investment.interestRate != nil {
                    Section {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            HStack {
                                Text("Calculated Maturity Value")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.secondaryText)

                                Spacer()

                                Button {
                                    newValue = String(calculatedValue)
                                } label: {
                                    Text("Use This")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(AppTheme.Colors.accent)
                                }
                            }

                            Text(calculatedValue.toCurrency())
                                .font(AppTheme.Typography.financialLarge)
                                .foregroundStyle(AppTheme.Colors.profit)

                            Text("Based on \(String(format: "%.2f", investment.interestRate ?? 0))% interest rate")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.tertiaryText)
                        }
                    } header: {
                        Text("Suggested Value")
                    }
                }

                Section("New Value") {
                    TextField("Enter new value", text: $newValue)
                        .keyboardType(.numberPad)
                        .font(AppTheme.Typography.financialMedium)

                    if let newVal = Int(newValue), newVal > 0 {
                        let profit = newVal - investment.initialAmount
                        let profitPct = (Double(profit) / Double(investment.initialAmount)) * 100

                        VStack(spacing: AppTheme.Spacing.sm) {
                            LabeledContent("Profit/Loss", value: profit.toCurrency())
                                .foregroundStyle(profit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)

                            LabeledContent("Return", value: String(format: "%.2f%%", profitPct))
                                .foregroundStyle(profit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        }
                    }
                }
            }
            .navigationTitle("Update Maturity Value")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        Task {
                            await updateValue()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .task {
                // Pre-fill with calculated value if available
                if investment.interestRate != nil {
                    newValue = String(calculatedValue)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }

    private var isFormValid: Bool {
        guard let value = Int(newValue) else { return false }
        return value > 0
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func updateValue() async {
        guard let value = Double(newValue) else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await investmentService.updateCurrentValue(investment.id, value)
            onSave?()
            dismiss()
        } catch {
            errorMessage = "Failed to update value: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    MaturityBannerView(
        investment: .mockDeposito,
        onUpdateValue: {}
    )
    .padding()
}
