// MARK: - Request Parameters
struct CreateAccountParams: Codable, Sendable {
    let name: String
    let category: String
    let currency: String
    let accountNumber: String?
    let initialBalance: Int

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case currency
        case accountNumber = "account_number"
        case initialBalance = "initial_balance"
    }
}
