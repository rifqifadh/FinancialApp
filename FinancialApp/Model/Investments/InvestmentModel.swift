import Foundation

struct InvestmentModel: Identifiable, Codable, Sendable, Equatable {
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
        case pricePerUnit = "price_per_unit"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)

        let typeString = try container.decode(String.self, forKey: .type)
        type = InvestmentType(rawValue: typeString) ?? .other

        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName)

        // Handle amounts as string from JSON
        let initialAmountString = try container.decode(String.self, forKey: .initialAmount)
        initialAmount = Int(initialAmountString) ?? 0

        let currentValueString = try container.decode(String.self, forKey: .currentValue)
        currentValue = Int(currentValueString) ?? 0

        // Handle dates
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let purchaseDateString = try container.decode(String.self, forKey: .purchaseDate)
        if let date = dateFormatter.date(from: purchaseDateString) {
            purchaseDate = date
        } else {
            purchaseDate = Date()
        }

        if let maturityDateString = try container.decodeIfPresent(String.self, forKey: .maturityDate),
           let date = dateFormatter.date(from: maturityDateString) {
            maturityDate = date
        } else {
            maturityDate = nil
        }

        interestRate = try container.decodeIfPresent(Double.self, forKey: .interestRate)
        units = try container.decodeIfPresent(Double.self, forKey: .units)

        if let pricePerUnitString = try container.decodeIfPresent(String.self, forKey: .pricePerUnit) {
            pricePerUnit = Int(pricePerUnitString)
        } else {
            pricePerUnit = nil
        }

        notes = try container.decodeIfPresent(String.self, forKey: .notes)

        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = nil
        }

        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(accountId, forKey: .accountId)
        try container.encodeIfPresent(accountName, forKey: .accountName)
        try container.encode(String(initialAmount), forKey: .initialAmount)
        try container.encode(String(currentValue), forKey: .currentValue)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: purchaseDate), forKey: .purchaseDate)
        if let maturityDate = maturityDate {
            try container.encode(formatter.string(from: maturityDate), forKey: .maturityDate)
        }

        try container.encodeIfPresent(interestRate, forKey: .interestRate)
        try container.encodeIfPresent(units, forKey: .units)
        if let pricePerUnit = pricePerUnit {
            try container.encode(String(pricePerUnit), forKey: .pricePerUnit)
        }
        try container.encodeIfPresent(notes, forKey: .notes)

        if let createdAt = createdAt {
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
        if let updatedAt = updatedAt {
            try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        }
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
extension InvestmentModel {
    static let mockDeposito = InvestmentModel(
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

    static let mockStocks = InvestmentModel(
        id: "2",
        userId: "user1",
        name: "BBCA - Bank Central Asia",
        type: .stocks,
        accountId: "acc2",
        accountName: "Stockbit",
        initialAmount: 5000000,
        currentValue: 6500000,
        purchaseDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
        units: 500,
        pricePerUnit: 10000,
        notes: "Blue chip banking stock"
    )

    static let mockReksaDana = InvestmentModel(
        id: "3",
        userId: "user1",
        name: "Sucorinvest Equity Fund",
        type: .reksaDanaSaham,
        accountId: "acc3",
        accountName: "Bareksa",
        initialAmount: 3000000,
        currentValue: 3450000,
        purchaseDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
        units: 2500,
        pricePerUnit: 1200,
        notes: "Reksa dana saham dengan performa bagus"
    )

    static let mockObligation = InvestmentModel(
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

    static let mockGold = InvestmentModel(
        id: "5",
        userId: "user1",
        name: "Emas Antam",
        type: .gold,
        accountId: nil,
        accountName: "Physical",
        initialAmount: 8000000,
        currentValue: 9200000,
        purchaseDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
        units: 10,
        pricePerUnit: 800000,
        notes: "10 gram emas Antam"
    )

    static let mockInvestments = [mockDeposito, mockStocks, mockReksaDana, mockObligation, mockGold]
}
