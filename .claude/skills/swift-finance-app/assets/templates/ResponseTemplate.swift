//
//  TEMPLATE: Model
//  
//  Replace [Item] with your model name (e.g., Expense, Asset)
//  Replace field names with your actual database columns
//

import Foundation

nonisolated struct [Item]Response: Codable, Sendable {
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    let field1: String
    let field2: Decimal
    let field3: Date
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - CodingKeys
    
    /// Map Swift property names to database column names (snake_case)
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case field1 = "field_1"
        case field2 = "field_2"
        case field3 = "field_3"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        field1: String,
        field2: Decimal,
        field3: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.field1 = field1
        self.field2 = field2
        self.field3 = field3
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Sample Data (for previews)

extension [Item]Response {
    static var sample: [Item] {
        [Item](
            userId: UUID(),
            field1: "Sample",
            field2: 100.00,
            field3: Date()
        )
    }
    
    static var samples: [[Item]] {
        [
            sample,
            [Item](
                userId: UUID(),
                field1: "Another Sample",
                field2: 250.50,
                field3: Date()
            )
        ]
    }
}
