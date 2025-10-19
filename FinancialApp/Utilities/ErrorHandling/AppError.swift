import Foundation

/// Main error type for the application
enum AppError: LocalizedError, Sendable {
    // MARK: - Network Errors
    case networkError(NetworkError)

    // MARK: - Authentication Errors
    case authError(AuthError)

    // MARK: - Database Errors
    case databaseError(DatabaseError)

    // MARK: - Validation Errors
    case validationError(ValidationError)

    // MARK: - Expense Errors
    case expenseError(ExpenseError)

    // MARK: - Unknown Error
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return error.errorDescription
        case .authError(let error):
            return error.errorDescription
        case .databaseError(let error):
            return error.errorDescription
        case .validationError(let error):
            return error.errorDescription
        case .expenseError(let error):
            return error.errorDescription
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError(let error):
            return error.recoverySuggestion
        case .authError(let error):
            return error.recoverySuggestion
        case .databaseError(let error):
            return error.recoverySuggestion
        case .validationError(let error):
            return error.recoverySuggestion
        case .expenseError(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Please try again or contact support if the problem persists."
        }
    }

    var failureReason: String? {
        switch self {
        case .networkError(let error):
            return error.failureReason
        case .authError(let error):
            return error.failureReason
        case .databaseError(let error):
            return error.failureReason
        case .validationError(let error):
            return error.failureReason
        case .expenseError(let error):
            return error.failureReason
        case .unknown:
            return "The cause is unknown."
        }
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError, Sendable {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingError(String)
    case encodingError(String)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let statusCode):
            return "Server error (\(statusCode))"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let message):
            return "Data decoding failed: \(message)"
        case .encodingError(let message):
            return "Data encoding failed: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "The server encountered an error. Please try again later."
        case .invalidResponse:
            return "Please try again or contact support."
        case .decodingError, .encodingError:
            return "Please update the app or contact support."
        }
    }

    var failureReason: String? {
        switch self {
        case .noConnection:
            return "The device is not connected to the internet."
        case .timeout:
            return "The server took too long to respond."
        case .serverError(let statusCode):
            return "The server returned status code \(statusCode)."
        case .invalidResponse:
            return "The server response format is invalid."
        case .decodingError(let message):
            return message
        case .encodingError(let message):
            return message
        }
    }
}

// MARK: - Authentication Errors
enum AuthError: LocalizedError, Sendable {
    case notAuthenticated
    case invalidCredentials
    case sessionExpired
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case userNotFound
    case accountDisabled
    case tooManyRequests
    case providerSignInFailed(provider: String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case .invalidCredentials:
            return "Invalid credentials"
        case .sessionExpired:
            return "Session expired"
        case .emailAlreadyInUse:
            return "Email already in use"
        case .weakPassword:
            return "Password is too weak"
        case .invalidEmail:
            return "Invalid email address"
        case .userNotFound:
            return "User not found"
        case .accountDisabled:
            return "Account disabled"
        case .tooManyRequests:
            return "Too many requests"
        case .providerSignInFailed(let provider):
            return "\(provider) sign-in failed"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue."
        case .invalidCredentials:
            return "Please check your email and password and try again."
        case .sessionExpired:
            return "Please sign in again."
        case .emailAlreadyInUse:
            return "This email is already registered. Please sign in or use a different email."
        case .weakPassword:
            return "Please use a stronger password with at least 8 characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .userNotFound:
            return "Please check your email or create a new account."
        case .accountDisabled:
            return "Please contact support to reactivate your account."
        case .tooManyRequests:
            return "Please wait a moment and try again."
        case .providerSignInFailed:
            return "Please try again or use a different sign-in method."
        }
    }

    var failureReason: String? {
        switch self {
        case .notAuthenticated:
            return "No active user session found."
        case .invalidCredentials:
            return "The email or password is incorrect."
        case .sessionExpired:
            return "Your session has expired."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "The password does not meet security requirements."
        case .invalidEmail:
            return "The email format is invalid."
        case .userNotFound:
            return "No account exists with this email."
        case .accountDisabled:
            return "This account has been disabled."
        case .tooManyRequests:
            return "Too many authentication attempts."
        case .providerSignInFailed(let provider):
            return "Failed to authenticate with \(provider)."
        }
    }
}

// MARK: - Database Errors
enum DatabaseError: LocalizedError, Sendable {
    case queryFailed(String)
    case insertFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case notFound(resource: String)
    case permissionDenied
    case constraintViolation(String)

    var errorDescription: String? {
        switch self {
        case .queryFailed:
            return "Failed to fetch data"
        case .insertFailed:
            return "Failed to create record"
        case .updateFailed:
            return "Failed to update record"
        case .deleteFailed:
            return "Failed to delete record"
        case .notFound(let resource):
            return "\(resource) not found"
        case .permissionDenied:
            return "Permission denied"
        case .constraintViolation:
            return "Data constraint violation"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .queryFailed, .insertFailed, .updateFailed, .deleteFailed:
            return "Please try again or contact support if the problem persists."
        case .notFound:
            return "The requested item could not be found. It may have been deleted."
        case .permissionDenied:
            return "You don't have permission to perform this action."
        case .constraintViolation:
            return "Please check your input and try again."
        }
    }

    var failureReason: String? {
        switch self {
        case .queryFailed(let message):
            return "Query failed: \(message)"
        case .insertFailed(let message):
            return "Insert failed: \(message)"
        case .updateFailed(let message):
            return "Update failed: \(message)"
        case .deleteFailed(let message):
            return "Delete failed: \(message)"
        case .notFound(let resource):
            return "\(resource) does not exist in the database."
        case .permissionDenied:
            return "Insufficient permissions."
        case .constraintViolation(let message):
            return "Constraint violation: \(message)"
        }
    }
}

// MARK: - Validation Errors
enum ValidationError: LocalizedError, Sendable {
    case emptyField(fieldName: String)
    case invalidFormat(fieldName: String, expectedFormat: String)
    case outOfRange(fieldName: String, min: String?, max: String?)
    case invalidAmount(reason: String)
    case invalidDate(reason: String)
    case missingRequiredField(fieldName: String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) cannot be empty"
        case .invalidFormat(let field, _):
            return "Invalid \(field) format"
        case .outOfRange(let field, _, _):
            return "\(field) is out of range"
        case .invalidAmount:
            return "Invalid amount"
        case .invalidDate:
            return "Invalid date"
        case .missingRequiredField(let field):
            return "\(field) is required"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyField(let field):
            return "Please enter a value for \(field)."
        case .invalidFormat(let field, let format):
            return "\(field) must be in \(format) format."
        case .outOfRange(let field, let min, let max):
            if let min = min, let max = max {
                return "\(field) must be between \(min) and \(max)."
            } else if let min = min {
                return "\(field) must be at least \(min)."
            } else if let max = max {
                return "\(field) must be at most \(max)."
            }
            return "Please enter a valid value for \(field)."
        case .invalidAmount(let reason):
            return reason
        case .invalidDate(let reason):
            return reason
        case .missingRequiredField(let field):
            return "Please provide a value for \(field)."
        }
    }

    var failureReason: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) is empty."
        case .invalidFormat(let field, let format):
            return "\(field) does not match the expected format: \(format)."
        case .outOfRange(let field, let min, let max):
            if let min = min, let max = max {
                return "\(field) is not between \(min) and \(max)."
            } else if let min = min {
                return "\(field) is less than \(min)."
            } else if let max = max {
                return "\(field) is greater than \(max)."
            }
            return "\(field) is out of the acceptable range."
        case .invalidAmount(let reason):
            return reason
        case .invalidDate(let reason):
            return reason
        case .missingRequiredField(let field):
            return "\(field) was not provided."
        }
    }
}

// MARK: - Expense Errors
enum ExpenseError: LocalizedError, Sendable {
    case invalidAmount
    case amountTooLarge
    case amountNegative
    case futureDate
    case categoryNotFound
    case duplicateExpense
    case insufficientData

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid expense amount"
        case .amountTooLarge:
            return "Amount is too large"
        case .amountNegative:
            return "Amount cannot be negative"
        case .futureDate:
            return "Cannot create expense for future date"
        case .categoryNotFound:
            return "Category not found"
        case .duplicateExpense:
            return "Duplicate expense detected"
        case .insufficientData:
            return "Insufficient expense data"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount."
        case .amountTooLarge:
            return "Please enter a smaller amount."
        case .amountNegative:
            return "Please enter a positive amount."
        case .futureDate:
            return "Please select today or a past date."
        case .categoryNotFound:
            return "Please select a valid category."
        case .duplicateExpense:
            return "This expense may already exist. Please check your expense list."
        case .insufficientData:
            return "Please fill in all required fields."
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidAmount:
            return "The amount is not a valid number."
        case .amountTooLarge:
            return "The amount exceeds the maximum allowed value."
        case .amountNegative:
            return "The amount is less than zero."
        case .futureDate:
            return "The expense date is in the future."
        case .categoryNotFound:
            return "The selected category does not exist."
        case .duplicateExpense:
            return "An expense with similar details already exists."
        case .insufficientData:
            return "Required expense information is missing."
        }
    }
}

// MARK: - Error Helper
extension AppError {
    /// Creates an AppError from any Error
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        } else if let networkError = error as? NetworkError {
            return .networkError(networkError)
        } else if let authError = error as? AuthError {
            return .authError(authError)
        } else if let databaseError = error as? DatabaseError {
            return .databaseError(databaseError)
        } else if let validationError = error as? ValidationError {
            return .validationError(validationError)
        } else if let expenseError = error as? ExpenseError {
            return .expenseError(expenseError)
        } else {
            return .unknown(error)
        }
    }

    /// Whether this error should be logged for debugging
    var shouldLog: Bool {
        switch self {
        case .networkError(.noConnection), .authError(.notAuthenticated):
            return false // Common, expected errors
        default:
            return true
        }
    }

    /// Whether this error should be reported to crash analytics
    var shouldReport: Bool {
        switch self {
        case .unknown, .networkError(.serverError), .databaseError:
            return true
        default:
            return false
        }
    }
}
