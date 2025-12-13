//
//  InvestmentResponse.swift
//  FinancialApp
//
//  Created by Rifqi Fadhlillah on 10/12/25.
//

import Foundation

struct InvestmentResponse: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let userId: String
    let name: String
    let type: InvestmentType
    let accountId: String?
    let accountName: String?
    let initialAmount: Int
    let currentValue: Int
    let purchaseDate: Date
    let maturityDate: Date?
    let interestRate: Double?
    let units: Double?
    let initialPricePerUnit: Double?
    let pricePerUnit: Int?
    let notes: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case accountId = "account_id"
        case accountName = "account_name"
        case initialAmount = "initial_amount"
        case currentValue = "current_value"
        case purchaseDate = "purchase_date"
        case maturityDate = "maturity_date"
        case interestRate = "interest_rate"
        case units
        case initialPricePerUnit = "initial_price_per_unit"
        case pricePerUnit = "price_per_unit"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Computed properties
    var profit: Int {
        currentValue - initialAmount
    }

    var profitPercentage: Double {
        guard initialAmount > 0 else { return 0 }
        return (Double(profit) / Double(initialAmount)) * 100
    }

    var isProfit: Bool {
        profit > 0
    }

    var isLoss: Bool {
        profit < 0
    }

    var daysHeld: Int {
        Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0
    }

    var daysUntilMaturity: Int? {
        guard let maturityDate = maturityDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: maturityDate).day
    }

    var isMatured: Bool {
        guard let maturityDate = maturityDate else { return false }
        return Date() >= maturityDate
    }

    var icon: String {
        type.icon
    }

    // Computed property for Lot (units / 100)
    var lot: Double? {
        guard let units = units else { return nil }
        return units / 100
    }

    // Custom initializer for manual creation
    init(
        id: String,
        userId: String,
        name: String,
        type: InvestmentType,
        accountId: String? = nil,
        accountName: String? = nil,
        initialAmount: Int,
        currentValue: Int,
        purchaseDate: Date,
        maturityDate: Date? = nil,
        interestRate: Double? = nil,
        units: Double? = nil,
        initialPricePerUnit: Double? = nil,
        pricePerUnit: Int? = nil,
        notes: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.accountId = accountId
        self.accountName = accountName
        self.initialAmount = initialAmount
        self.currentValue = currentValue
        self.purchaseDate = purchaseDate
        self.maturityDate = maturityDate
        self.interestRate = interestRate
        self.units = units
        self.initialPricePerUnit = initialPricePerUnit
        self.pricePerUnit = pricePerUnit
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Investment Type
enum InvestmentType: String, Codable, CaseIterable, Sendable {
    case deposito = "Deposito"
    case obligation = "Obligasi"
    case stocks = "Saham"
    case reksaDanaPasarUang = "Reksa Dana Pasar Uang"
    case reksaDanaPendapatanTetap = "Reksa Dana Pendapatan Tetap"
    case reksaDanaCampuran = "Reksa Dana Campuran"
    case reksaDanaSaham = "Reksa Dana Saham"
    case gold = "Emas"
    case sukuk = "Sukuk"
    case property = "Properti"
    case crypto = "Cryptocurrency"
    case other = "Lainnya"

    var icon: String {
        switch self {
        case .deposito:
            return "banknote"
        case .obligation, .sukuk:
            return "doc.text"
        case .stocks:
            return "chart.line.uptrend.xyaxis"
        case .reksaDanaPasarUang:
            return "dollarsign.circle"
        case .reksaDanaPendapatanTetap:
            return "chart.bar"
        case .reksaDanaCampuran:
            return "chart.pie"
        case .reksaDanaSaham:
            return "chart.line.uptrend.xyaxis.circle"
        case .gold:
            return "circle.hexagongrid.circle"
        case .property:
            return "house"
        case .crypto:
            return "bitcoinsign.circle"
        case .other:
            return "folder"
        }
    }

    var displayName: String {
        rawValue
    }

    var shortName: String {
        switch self {
        case .deposito:
            return "Deposito"
        case .obligation:
            return "Obligasi"
        case .stocks:
            return "Saham"
        case .reksaDanaPasarUang:
            return "RD Pasar Uang"
        case .reksaDanaPendapatanTetap:
            return "RD Pendapatan Tetap"
        case .reksaDanaCampuran:
            return "RD Campuran"
        case .reksaDanaSaham:
            return "RD Saham"
        case .gold:
            return "Emas"
        case .sukuk:
            return "Sukuk"
        case .property:
            return "Properti"
        case .crypto:
            return "Crypto"
        case .other:
            return "Lainnya"
        }
    }
}

// MARK: - Mock Data
extension InvestmentResponse {
    static let mockDeposito = InvestmentResponse(
        id: "1",
        userId: "user1",
        name: "Deposito BCA 6 Bulan",
        type: .deposito,
        accountId: "acc1",
        accountName: "BCA",
        initialAmount: 10000000,
        currentValue: 10250000,
        purchaseDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
        maturityDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
        interestRate: 5.0,
        notes: "Deposito 6 bulan dengan bunga 5% per tahun"
    )

    static let mockMaturedDeposito = InvestmentResponse(
        id: "6",
        userId: "user1",
        name: "Deposito Mandiri 12 Bulan",
        type: .deposito,
        accountId: "acc1",
        accountName: "Mandiri",
        initialAmount: 50000000,
        currentValue: 50000000, // Not yet updated
        purchaseDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
        maturityDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, // Matured 5 days ago
        interestRate: 4.5,
        notes: "Deposito yang sudah jatuh tempo, perlu update nilai"
    )

    static let mockStocks = InvestmentResponse(
        id: "2",
        userId: "user1",
        name: "BBCA - Bank Central Asia",
        type: .stocks,
        accountId: "acc2",
        accountName: "Stockbit",
        initialAmount: 5000000,
        currentValue: 6500000,
        purchaseDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
        units: 50000, // 500 lot
        initialPricePerUnit: 10000,
        pricePerUnit: 13000, // Current price
        notes: "Blue chip banking stock"
    )

    static let mockReksaDana = InvestmentResponse(
        id: "3",
        userId: "user1",
        name: "Sucorinvest Equity Fund",
        type: .reksaDanaSaham,
        accountId: "acc3",
        accountName: "Bareksa",
        initialAmount: 3000000,
        currentValue: 3450000,
        purchaseDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
        units: 250000, // 2500 lot
        initialPricePerUnit: 1200,
        pricePerUnit: 1380, // Current price
        notes: "Reksa dana saham dengan performa bagus"
    )

    static let mockObligation = InvestmentResponse(
        id: "4",
        userId: "user1",
        name: "SBR010 - Savings Bond Ritel",
        type: .obligation,
        accountId: "acc1",
        accountName: "BCA",
        initialAmount: 5000000,
        currentValue: 5150000,
        purchaseDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
        maturityDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
        interestRate: 6.0,
        notes: "Obligasi pemerintah 2 tahun"
    )

    static let mockGold = InvestmentResponse(
        id: "5",
        userId: "user1",
        name: "Emas Antam",
        type: .gold,
        accountId: nil,
        accountName: "Physical",
        initialAmount: 8000000,
        currentValue: 9200000,
        purchaseDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
        units: 1000, // 10 lot (gram)
        initialPricePerUnit: 800000,
        pricePerUnit: 920000, // Current price
        notes: "10 gram emas Antam"
    )

    static let mockInvestments = [mockDeposito, mockStocks, mockReksaDana, mockObligation, mockGold]
}
