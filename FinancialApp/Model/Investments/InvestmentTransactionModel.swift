import Foundation

struct InvestmentTransactionModel: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let investmentId: String
    let type: InvestmentTransactionType
    let units: Double
    let pricePerUnit: Int
    let totalAmount: Int
    let transactionDate: Date
    let notes: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case investmentId = "investment_id"
        case type
        case units
        case pricePerUnit = "price_per_unit"
        case totalAmount = "total_amount"
        case transactionDate = "transaction_date"
        case notes
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        investmentId = try container.decode(String.self, forKey: .investmentId)

        let typeString = try container.decode(String.self, forKey: .type)
        type = InvestmentTransactionType(rawValue: typeString) ?? .buy

        units = try container.decode(Double.self, forKey: .units)

        // Handle amounts as string from JSON
        let pricePerUnitString = try container.decode(String.self, forKey: .pricePerUnit)
        pricePerUnit = Int(pricePerUnitString) ?? 0

        let totalAmountString = try container.decode(String.self, forKey: .totalAmount)
        totalAmount = Int(totalAmountString) ?? 0

        // Handle dates
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
        if let date = dateFormatter.date(from: transactionDateString) {
            transactionDate = date
        } else {
            transactionDate = Date()
        }

        notes = try container.decodeIfPresent(String.self, forKey: .notes)

        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(investmentId, forKey: .investmentId)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(units, forKey: .units)
        try container.encode(String(pricePerUnit), forKey: .pricePerUnit)
        try container.encode(String(totalAmount), forKey: .totalAmount)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: transactionDate), forKey: .transactionDate)
        try container.encodeIfPresent(notes, forKey: .notes)

        if let createdAt = createdAt {
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
    }

    // Custom initializer
    init(
        id: String,
        investmentId: String,
        type: InvestmentTransactionType,
        units: Double,
        pricePerUnit: Int,
        totalAmount: Int,
        transactionDate: Date,
        notes: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.investmentId = investmentId
        self.type = type
        self.units = units
        self.pricePerUnit = pricePerUnit
        self.totalAmount = totalAmount
        self.transactionDate = transactionDate
        self.notes = notes
        self.createdAt = createdAt
    }

    // Computed properties
    var icon: String {
        type.icon
    }

    var color: String {
        type.colorName
    }

    var displayAmount: Int {
        switch type {
        case .buy:
            return -totalAmount // Money out
        case .sell:
            return totalAmount // Money in
        case .dividend:
            return totalAmount // Money in
        }
    }
}

// MARK: - Transaction Type
enum InvestmentTransactionType: String, Codable, CaseIterable, Sendable {
    case buy = "Buy"
    case sell = "Sell"
    case dividend = "Dividend"

    var icon: String {
        switch self {
        case .buy:
            return "arrow.down.circle.fill"
        case .sell:
            return "arrow.up.circle.fill"
        case .dividend:
            return "dollarsign.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .buy:
            return "loss" // Red for money out
        case .sell:
            return "profit" // Green for money in
        case .dividend:
            return "profit" // Green for income
        }
    }

    var displayName: String {
        rawValue
    }
}

// MARK: - Mock Data
extension InvestmentTransactionModel {
    static let mockBuy1 = InvestmentTransactionModel(
        id: "1",
        investmentId: "2",
        type: .buy,
        units: 100,
        pricePerUnit: 10000,
        totalAmount: 1000000,
        transactionDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
        notes: "Initial purchase"
    )

    static let mockBuy2 = InvestmentTransactionModel(
        id: "2",
        investmentId: "2",
        type: .buy,
        units: 200,
        pricePerUnit: 11000,
        totalAmount: 2200000,
        transactionDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
        notes: "Added more shares"
    )

    static let mockBuy3 = InvestmentTransactionModel(
        id: "3",
        investmentId: "2",
        type: .buy,
        units: 200,
        pricePerUnit: 9500,
        totalAmount: 1900000,
        transactionDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
        notes: "Bought the dip"
    )

    static let mockDividend1 = InvestmentTransactionModel(
        id: "4",
        investmentId: "2",
        type: .dividend,
        units: 500,
        pricePerUnit: 200,
        totalAmount: 100000,
        transactionDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
        notes: "Quarterly dividend"
    )

    static let mockSell1 = InvestmentTransactionModel(
        id: "5",
        investmentId: "2",
        type: .sell,
        units: 100,
        pricePerUnit: 12000,
        totalAmount: 1200000,
        transactionDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
        notes: "Took some profit"
    )

    static let mockDividend2 = InvestmentTransactionModel(
        id: "6",
        investmentId: "2",
        type: .dividend,
        units: 400,
        pricePerUnit: 200,
        totalAmount: 80000,
        transactionDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        notes: "Quarterly dividend"
    )

    static let mockTransactions = [mockBuy1, mockBuy2, mockBuy3, mockDividend1, mockSell1, mockDividend2]
}
