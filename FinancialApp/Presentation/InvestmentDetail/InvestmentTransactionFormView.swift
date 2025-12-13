import SwiftUI
import Dependencies

struct InvestmentTransactionFormView: View {
  @Environment(\.dismiss) private var dismiss
  @Dependency(\.investmentTransactionService) var transactionService
  
  let investment: InvestmentResponse
  var existingTransaction: InvestmentTransactionModel?
  var preselectedType: InvestmentTransactionType?
  var onSave: (() -> Void)?
  
  @State private var selectedType: InvestmentTransactionType = .buy
  @State private var lot = ""
  @State private var pricePerUnit = ""
  @State private var transactionDate = Date()
  @State private var notes = ""
  
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var showingError = false
  
  var isEditing: Bool {
    existingTransaction != nil
  }
  
  var calculatedTotal: Int {
    guard let lotValue = Double(lot),
          let priceValue = Int(pricePerUnit) else {
      return 0
    }
    // Convert lot to units (lot * 100)
    let unitsValue = lotValue * 100
    return Int(unitsValue * Double(priceValue))
  }
  
  var body: some View {
    NavigationStack {
      Form {
        // Transaction Type
        Section("Transaction Type") {
          Picker("Type", selection: $selectedType) {
            ForEach(InvestmentTransactionType.allCases, id: \.self) { type in
                Text(type.displayName)
                  .tag(type)
            }
          }
          .pickerStyle(.segmented)
        }
        
        // Lot & Price
        Section("Transaction Details") {
          HStack {
            TextField("Lot", text: $lot)
              .keyboardType(.decimalPad)

            Text("lot")
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          HStack {
            TextField("Price per unit", text: $pricePerUnit)
              .keyboardType(.numberPad)
            
            Text("per unit")
              .foregroundStyle(AppTheme.Colors.secondaryText)
          }
          
          // Calculated Total
          HStack {
            Text("Total Amount")
              .foregroundStyle(AppTheme.Colors.secondaryText)
            
            Spacer()
            
            Text(calculatedTotal.toCurrency())
              .font(AppTheme.Typography.bodyBold)
              .foregroundStyle(transactionColor)
          }
          
          // Cash flow indicator
          HStack {
            Image(systemName: cashFlowIcon)
              .foregroundStyle(transactionColor)
            
            Text(cashFlowText)
              .font(AppTheme.Typography.caption)
              .foregroundStyle(transactionColor)
          }
        }
        
        // Date
        Section("Date") {
          DatePicker("Transaction Date", selection: $transactionDate, displayedComponents: .date)
        }
        
        // Notes
        Section("Notes") {
          TextField("Notes (optional)", text: $notes, axis: .vertical)
            .lineLimit(3...6)
        }
        
        // Investment Info
        Section("Investment") {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(investment.name)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.primaryText)
              
              Text(investment.type.displayName)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
            
            Spacer()
            
            Image(systemName: investment.icon)
              .font(.system(size: 20))
              .foregroundStyle(AppTheme.Colors.accent)
          }
        }
      }
      .navigationTitle(isEditing ? "Edit Transaction" : "Add Transaction")
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
              await saveTransaction()
            }
          }
          .disabled(!isFormValid)
        }
      }
      .task {
        if let transaction = existingTransaction {
          populateForm(with: transaction)
        } else if let preselected = preselectedType {
          selectedType = preselected
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
    !lot.isEmpty &&
    !pricePerUnit.isEmpty &&
    Double(lot) != nil &&
    Int(pricePerUnit) != nil &&
    calculatedTotal > 0
  }
  
  private var transactionColor: Color {
    switch selectedType {
    case .buy:
      return AppTheme.Colors.loss
    case .sell, .dividend:
      return AppTheme.Colors.profit
    }
  }
  
  private var cashFlowIcon: String {
    switch selectedType {
    case .buy:
      return "arrow.down.circle.fill"
    case .sell, .dividend:
      return "arrow.up.circle.fill"
    }
  }
  
  private var cashFlowText: String {
    switch selectedType {
    case .buy:
      return "Money Out"
    case .sell:
      return "Money In"
    case .dividend:
      return "Income"
    }
  }
  
  private func populateForm(with transaction: InvestmentTransactionModel) {
    selectedType = transaction.type
    // Convert units to lot (units / 100)
    lot = String(transaction.lot)
    pricePerUnit = String(transaction.pricePerUnit)
    transactionDate = transaction.transactionDate
    notes = transaction.notes ?? ""
  }
  
  private func saveTransaction() async {
    guard isFormValid else { return }
    
    isLoading = true
    defer { isLoading = false }
    
    do {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      // Convert lot to units (lot * 100)
      let unitsValue = (Double(lot) ?? 0) * 100

      let params = CreateInvestmentTransactionParams(
        investmentId: investment.id,
        type: selectedType.rawValue,
        units: unitsValue,
        pricePerUnit: Int(pricePerUnit) ?? 0,
        totalAmount: calculatedTotal,
        transactionDate: formatter.string(from: transactionDate),
        notes: notes.isEmpty ? nil : notes
      )

      if isEditing, let transaction = existingTransaction {
        let updateParams = UpdateInvestmentTransactionParams(
          type: selectedType.rawValue,
          units: unitsValue,
          pricePerUnit: Int(pricePerUnit),
          totalAmount: calculatedTotal,
          transactionDate: formatter.string(from: transactionDate),
          notes: notes.isEmpty ? nil : notes
        )
        try await transactionService.update(transaction.id, updateParams)
      } else {
        try await transactionService.create(params)
      }
      
      onSave?()
      dismiss()
    } catch {
      errorMessage = "Failed to save transaction: \(error.localizedDescription)"
      showingError = true
    }
  }
}

// MARK: - Preview
#Preview {
  InvestmentTransactionFormView(investment: .mockStocks)
}
