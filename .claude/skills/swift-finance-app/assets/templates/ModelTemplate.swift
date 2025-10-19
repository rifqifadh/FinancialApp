//
//  TEMPLATE: Model
//  
//  Replace [Item] with your model name (e.g., Expense, Asset)
//  Replace field names with your actual database columns
//

import Foundation

struct [Item]: dentifiable, Hashable {
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    let field1: String
    let field2: Decimal
    let field3: Date
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Example computed property
    var displayName: String {
        "\(field1) - \(field2)"
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
