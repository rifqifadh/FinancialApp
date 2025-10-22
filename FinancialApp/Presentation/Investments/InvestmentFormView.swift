import SwiftUI
import Dependencies

struct InvestmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.investmentService) var investmentService
    @Dependency(\.accountService) var accountService

    var existingInvestment: InvestmentModel?
    var onSave: (() -> Void)?

    @State private var name = ""
    @State private var selectedType: InvestmentType = .stocks
    @State private var selectedAccount: AccountModel?
    @State private var initialAmount = ""
    @State private var currentValue = ""
    @State private var purchaseDate = Date()
    @State private var maturityDate: Date?
    @State private var hasMaturityDate = false
    @State private var interestRate = ""
    @State private var hasInterestRate = false
    @State private var units = ""
    @State private var hasUnits = false
    @State private var pricePerUnit = ""
    @State private var notes = ""

    @State private var accounts: [AccountModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false

    var isEditing: Bool {
        existingInvestment != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic Information
                Section("Investment Details") {
                    TextField("Investment Name", text: $name)
                        .autocorrectionDisabled()

                    Picker("Type", selection: $selectedType) {
                        ForEach(InvestmentType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }

//                    Picker("Account", selection: $selectedAccount) {
//                        Text("None").tag(nil as AccountModel?)
//                        ForEach(accounts) { account in
//                            Text(account.name).tag(account as AccountModel?)
//                        }
//                    }
                }

                // Amount Information
                Section("Amount") {
                    TextField("Initial Amount", text: $initialAmount)
                        .keyboardType(.numberPad)

                    TextField("Current Value", text: $currentValue)
                        .keyboardType(.numberPad)

                    if !initialAmount.isEmpty && !currentValue.isEmpty,
                       let initial = Int(initialAmount),
                       let current = Int(currentValue),
                       initial > 0 {
                        let profit = current - initial
                        let percentage = (Double(profit) / Double(initial)) * 100

                        HStack {
                            Text("Gain/Loss")
                                .foregroundStyle(AppTheme.Colors.secondaryText)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(profit.toCurrency())
                                    .font(AppTheme.Typography.bodyBold)
                                    .foregroundStyle(profit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)

                                Text(String(format: "%.2f%%", percentage))
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(profit >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                            }
                        }
                    }
                }

                // Units & Price (for stocks, mutual funds, etc.)
                Section("Units & Price") {
                    Toggle("Has Units", isOn: $hasUnits)

                    if hasUnits {
                        TextField("Number of Units", text: $units)
                            .keyboardType(.decimalPad)

                        TextField("Price Per Unit", text: $pricePerUnit)
                            .keyboardType(.numberPad)
                    }
                }

                // Dates
                Section("Dates") {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)

                    Toggle("Has Maturity Date", isOn: $hasMaturityDate)

                    if hasMaturityDate {
                        DatePicker("Maturity Date", selection: Binding(
                            get: { maturityDate ?? Date() },
                            set: { maturityDate = $0 }
                        ), displayedComponents: .date)
                    }
                }

                // Interest Rate (for deposito, bonds, etc.)
                Section("Interest Rate") {
                    Toggle("Has Interest Rate", isOn: $hasInterestRate)

                    if hasInterestRate {
                        HStack {
                            TextField("Interest Rate", text: $interestRate)
                                .keyboardType(.decimalPad)

                            Text("% per year")
                                .foregroundStyle(AppTheme.Colors.secondaryText)
                        }
                    }
                }

                // Notes
                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Investment" : "Add Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Add") {
                        Task {
                            await saveInvestment()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .task {
                await loadAccounts()
                if let investment = existingInvestment {
                    populateForm(with: investment)
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
        !name.isEmpty &&
        !initialAmount.isEmpty &&
        !currentValue.isEmpty &&
        Int(initialAmount) != nil &&
        Int(currentValue) != nil
    }

    private func loadAccounts() async {
        do {
            accounts = try await accountService.fetchAll()
        } catch {
            errorMessage = "Failed to load accounts: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func populateForm(with investment: InvestmentModel) {
        name = investment.name
        selectedType = investment.type
        initialAmount = String(investment.initialAmount)
        currentValue = String(investment.currentValue)
        purchaseDate = investment.purchaseDate
        notes = investment.notes ?? ""

        if let maturity = investment.maturityDate {
            hasMaturityDate = true
            maturityDate = maturity
        }

        if let rate = investment.interestRate {
            hasInterestRate = true
            interestRate = String(rate)
        }

        if let investmentUnits = investment.units {
            hasUnits = true
            units = String(investmentUnits)
        }

        if let price = investment.pricePerUnit {
            pricePerUnit = String(price)
        }

        if let accountId = investment.accountId {
            selectedAccount = accounts.first { $0.id == accountId }
        }
    }

    private func saveInvestment() async {
        guard isFormValid else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let params = CreateInvestmentParams(
                name: name,
                type: selectedType.rawValue,
                accountId: selectedAccount?.id,
                initialAmount: Int(initialAmount) ?? 0,
                currentValue: Int(currentValue) ?? 0,
                purchaseDate: formatter.string(from: purchaseDate),
                maturityDate: hasMaturityDate ? maturityDate.map { formatter.string(from: $0) } : nil,
                interestRate: hasInterestRate ? Double(interestRate) : nil,
                units: hasUnits ? Double(units) : nil,
                pricePerUnit: hasUnits && !pricePerUnit.isEmpty ? Int(pricePerUnit) : nil,
                notes: notes.isEmpty ? nil : notes
            )

            if isEditing, let investment = existingInvestment {
                let updateParams = UpdateInvestmentParams(
                    name: name,
                    type: selectedType.rawValue,
                    accountId: selectedAccount?.id,
                    currentValue: Int(currentValue),
                    maturityDate: hasMaturityDate ? maturityDate.map { formatter.string(from: $0) } : nil,
                    interestRate: hasInterestRate ? Double(interestRate) : nil,
                    units: hasUnits ? Double(units) : nil,
                    pricePerUnit: hasUnits && !pricePerUnit.isEmpty ? Int(pricePerUnit) : nil,
                    notes: notes.isEmpty ? nil : notes
                )
                try await investmentService.update(investment.id, updateParams)
            } else {
                try await investmentService.create(params)
            }

            onSave?()
            dismiss()
        } catch {
            errorMessage = "Failed to save investment: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Preview
#Preview {
    InvestmentFormView()
}
