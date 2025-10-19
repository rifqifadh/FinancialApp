//
//  TEMPLATE: List View
//  
//  Replace [Feature] with your feature name (e.g., Expense, Asset)
//  Replace [Item] with your model name (e.g., Expense, Asset)
//

import SwiftUI

struct [Feature]ListView: View {
    // MARK: - Properties
    @StateObject private var viewModel = [Feature]ViewModel()
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    private var filteredItems: [[Item]] {
        if searchText.isEmpty {
            return viewModel.items
        }
        return viewModel.items.filter { item in
            // Customize search logic based on your model
            // item.name.localizedCaseInsensitiveContains(searchText)
            true
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    LoadingView(message: "Loading [items]...")
                } else if viewModel.items.isEmpty {
                    emptyStateView
                } else {
                    listView
                }
            }
            .navigationTitle("[Feature]s")
            .searchable(text: $searchText, prompt: "Search [items]")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add [Item]", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                [Feature]FormView { newItem in
                    Task {
                        let success = await viewModel.createItem(newItem)
                        if success {
                            showingAddSheet = false
                        }
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await viewModel.fetchItems()
            }
            .refreshable {
                await viewModel.fetchItems()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var listView: some View {
        List {
            ForEach(filteredItems) { item in
                NavigationLink(value: item) {
                    [Item]Row(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteItem(id: item.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: [Item].self) { item in
            [Feature]DetailView(item: item)
        }
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "tray",
            title: "No [Items] Yet",
            message: "Tap the + button to add your first [item]",
            actionTitle: "Add [Item]",
            action: {
                showingAddSheet = true
            }
        )
    }
}

// MARK: - Row Component

struct [Item]Row: View {
    let item: [Item]
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon or Image
            Circle()
                .fill(Color.blue)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "icon.name")
                        .foregroundColor(.white)
                }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Item Name")
                    .font(.headline)
                
                Text("Item Detail")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Trailing info
            Text("Value")
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    [Feature]ListView()
}
