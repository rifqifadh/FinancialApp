//
//  TEMPLATE: ViewModel
//  
//  Replace [Feature] with your feature name (e.g., Expense, Asset)
//  Replace [Item] with your model name (e.g., Expense, Asset)
//

import Observation
import Dependencies
import Foundation

@MainActor
@Observable
class [Feature]ViewModel {
    @ObservationIgnored
	@Dependency(\.[Feature]Service) var [Feature]Service
    // MARK: - Published Properties
    var items: [[Item]] = []
    var isLoading = false
    var errorMessage: String?
    var selectedItem: [Item]?
    
    // MARK: - Private Properties
    private let service: [Feature]Service
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    /// Fetch all items
    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await service.fetchAll()
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    /// Create a new item
    func createItem(_ item: [Item]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.create(item)
            await fetchItems() // Refresh list
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Update an existing item
    func updateItem(_ item: [Item]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.update(item)
            await fetchItems() // Refresh list
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Delete an item
    func deleteItem(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.delete(id: id)
            await fetchItems() // Refresh list
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) -> String {
        // Customize error messages based on your error types
        if let appError = error as? FinanceAppError {
            return appError.localizedDescription
        }
        return "An unexpected error occurred: \(error.localizedDescription)"
    }
}
