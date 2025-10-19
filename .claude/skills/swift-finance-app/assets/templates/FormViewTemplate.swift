//
//  TEMPLATE: Form View
//  
//  Replace [Feature] with your feature name (e.g., Expense, Asset)
//  Replace [Item] with your model name (e.g., Expense, Asset)
//

import SwiftUI

struct [Feature]FormView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    let onSave: ([Item]) -> Void
    let editingItem: [Item]?
    
    // MARK: - State
    @State private var field1 = ""
    @State private var field2 = ""
    @State private var selectedDate = Date()
    @State private var isSaving = false
    
    // MARK: - Computed Properties
    private var isValid: Bool {
        !field1.isEmpty && !field2.isEmpty
    }
    
    private var title: String {
        editingItem == nil ? "Add [Item]" : "Edit [Item]"
    }
    
    // MARK: - Initialization
    init(
        editingItem: [Item]? = nil,
        onSave: @escaping ([Item]) -> Void
    ) {
        self.editingItem = editingItem
        self.onSave = onSave
        
        // Initialize state from editing item
        if let item = editingItem {
            _field1 = State(initialValue: item.field1)
            _field2 = State(initialValue: item.field2)
            _selectedDate = State(initialValue: item.date)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                detailsSection
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .disabled(isSaving)
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section("Basic Information") {
            TextField("Field 1", text: $field1)
                .textContentType(.none)
                .autocorrectionDisabled()
            
            TextField("Field 2", text: $field2)
                .textContentType(.none)
                .autocorrectionDisabled()
            
            DatePicker(
                "Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            // Add additional form fields here
            Text("Additional fields")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func save() {
        isSaving = true
        
        // Create or update item
        let item = [Item](
            id: editingItem?.id ?? UUID(),
            field1: field1,
            field2: field2,
            date: selectedDate
            // Add other fields
        )
        
        onSave(item)
        
        // Don't dismiss here - let parent handle it after successful save
        isSaving = false
    }
}

// MARK: - Preview

#Preview("Add") {
    [Feature]FormView { item in
        print("Saved: \(item)")
    }
}

#Preview("Edit") {
    [Feature]FormView(
        editingItem: [Item](
            id: UUID(),
            field1: "Example",
            field2: "Data",
            date: Date()
        )
    ) { item in
        print("Updated: \(item)")
    }
}
