// MARK: - Add Account Mode
enum AccountFormMode: Equatable {
  case add
  case edit(AccountModel)

  var title: String {
    switch self {
    case .add:
      return "Add Account"
    case .edit:
      return "Edit Account"
    }
  }

  var saveButtonTitle: String {
    switch self {
    case .add:
      return "Add Account"
    case .edit:
      return "Save Changes"
    }
  }

  var account: AccountModel? {
    switch self {
    case .add:
      return nil
    case .edit(let account):
      return account
    }
  }
}