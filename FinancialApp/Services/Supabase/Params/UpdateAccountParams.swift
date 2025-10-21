struct UpdateAccountParams: Codable, Sendable {
    let name: String?
    let category: String?
    let accountNumber: String?

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case accountNumber = "account_number"
    }
}