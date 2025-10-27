struct TransactionParams: Encodable, Sendable {
  let month: Date = .init()
  let accountId: String?
}