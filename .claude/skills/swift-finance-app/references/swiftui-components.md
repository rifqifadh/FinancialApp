# SwiftUI Components for Financial Apps

This reference provides reusable SwiftUI components and patterns for building financial management interfaces.

## Table of Contents
- [Currency Formatting](#currency-formatting)
- [Chart Components](#chart-components)
- [List Components](#list-components)
- [Form Components](#form-components)
- [Card Components](#card-components)
- [Utility Views](#utility-views)

---

## Currency Formatting

### Currency Formatter Extension

```swift
extension Decimal {
    func formatAsCurrency(code: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}

extension Double {
    func formatAsCurrency(code: String = "USD") -> String {
        Decimal(self).formatAsCurrency(code: code)
    }
}
```

### Usage

```swift
Text(expense.amount.formatAsCurrency())
    .font(.title2)
    .fontWeight(.bold)
```

---

## Chart Components

### Expense Pie Chart

```swift
import Charts

struct ExpensePieChart: View {
    let categoryData: [CategoryExpense]
    
    var body: some View {
        Chart(categoryData) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Category", item.categoryName))
            .cornerRadius(5)
        }
        .frame(height: 300)
    }
}

struct CategoryExpense: Identifiable {
    let id = UUID()
    let categoryName: String
    let amount: Decimal
    let color: Color
}
```

### Monthly Spending Bar Chart

```swift
struct MonthlySpendingChart: View {
    let monthlyData: [MonthlyExpense]
    
    var body: some View {
        Chart(monthlyData) { item in
            BarMark(
                x: .value("Month", item.month, unit: .month),
                y: .value("Amount", item.totalAmount)
            )
            .foregroundStyle(Color.blue.gradient)
            .cornerRadius(8)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Decimal.self) {
                        Text(amount.formatAsCurrency())
                    }
                }
            }
        }
        .frame(height: 300)
    }
}

struct MonthlyExpense: Identifiable {
    let id = UUID()
    let month: Date
    let totalAmount: Decimal
}
```

### Line Chart for Investment Performance

```swift
struct InvestmentPerformanceChart: View {
    let performanceData: [InvestmentPoint]
    
    var body: some View {
        Chart(performanceData) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(Color.green.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.green.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Decimal.self) {
                        Text(amount.formatAsCurrency())
                    }
                }
            }
        }
        .frame(height: 250)
    }
}

struct InvestmentPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Decimal
}
```

---

## List Components

### Expense List Row

```swift
struct ExpenseRow: View {
    let expense: Expense
    let category: Category?
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Circle()
                .fill(Color(hex: category?.color ?? "#888888"))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: category?.iconName ?? "questionmark")
                        .foregroundColor(.white)
                }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description ?? "Expense")
                    .font(.headline)
                
                HStack {
                    Text(category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(expense.expenseDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(expense.amount.formatAsCurrency(code: expense.currency))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}
```

### Asset Card Row

```swift
struct AssetRow: View {
    let asset: Asset
    
    var valueChange: Decimal? {
        guard let current = asset.currentValue,
              let purchase = asset.purchasePrice else { return nil }
        return current - purchase
    }
    
    var percentageChange: Double? {
        guard let current = asset.currentValue,
              let purchase = asset.purchasePrice,
              purchase > 0 else { return nil }
        return Double(truncating: ((current - purchase) / purchase * 100) as NSDecimalNumber)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(asset.name)
                    .font(.headline)
                
                Spacer()
                
                Text(asset.assetType.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let value = asset.currentValue {
                        Text(value.formatAsCurrency(code: asset.currency))
                            .font(.title3)
                            .fontWeight(.semibold)
                    } else {
                        Text("Not set")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let change = valueChange, let percent = percentageChange {
                    VStack(alignment: .trailing) {
                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(abs(percent), specifier: "%.2f")%")
                        }
                        .font(.caption)
                        .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text(abs(change).formatAsCurrency(code: asset.currency))
                            .font(.caption)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
```

---

## Form Components

### Expense Entry Form

```swift
struct ExpenseForm: View {
    @Binding var amount: String
    @Binding var description: String
    @Binding var selectedCategory: Category?
    @Binding var date: Date
    @Binding var paymentMethod: String
    
    let categories: [Category]
    let paymentMethods = ["Cash", "Credit Card", "Debit Card", "Bank Transfer"]
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                
                TextField("Description", text: $description)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section("Category") {
                Picker("Category", selection: $selectedCategory) {
                    Text("Select Category").tag(nil as Category?)
                    ForEach(categories) { category in
                        HStack {
                            Image(systemName: category.iconName ?? "tag")
                            Text(category.name)
                        }
                        .tag(category as Category?)
                    }
                }
            }
            
            Section("Payment") {
                Picker("Payment Method", selection: $paymentMethod) {
                    ForEach(paymentMethods, id: \.self) { method in
                        Text(method).tag(method)
                    }
                }
            }
        }
    }
}
```

### Category Picker

```swift
struct CategoryPicker: View {
    @Binding var selectedCategory: Category?
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    )
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.iconName ?? "tag")
                .foregroundColor(isSelected ? .white : Color(hex: category.color ?? "#888888"))
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            isSelected ? Color(hex: category.color ?? "#888888") : Color(.systemGray6)
        )
        .cornerRadius(20)
    }
}
```

---

## Card Components

### Summary Card

```swift
struct SummaryCard: View {
    let title: String
    let amount: Decimal
    let currency: String
    let icon: String
    let color: Color
    let trend: TrendIndicator?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    TrendView(trend: trend)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(amount.formatAsCurrency(code: currency))
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct TrendIndicator {
    let percentage: Double
    let isPositive: Bool
}

struct TrendView: View {
    let trend: TrendIndicator
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trend.isPositive ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(trend.percentage), specifier: "%.1f")%")
        }
        .font(.caption)
        .foregroundColor(trend.isPositive ? .green : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (trend.isPositive ? Color.green : Color.red).opacity(0.15)
        )
        .cornerRadius(8)
    }
}
```

### Budget Progress Card

```swift
struct BudgetProgressCard: View {
    let budget: Budget
    let spent: Decimal
    let category: Category?
    
    var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(Double(truncating: (spent / budget.amount) as NSDecimalNumber), 1.0)
    }
    
    var remaining: Decimal {
        budget.amount - spent
    }
    
    var isOverBudget: Bool {
        spent > budget.amount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category?.name ?? "General")
                        .font(.headline)
                    
                    Text(budget.period.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(spent.formatAsCurrency(code: budget.currency))
                        .font(.headline)
                        .foregroundColor(isOverBudget ? .red : .primary)
                    
                    Text("of \(budget.amount.formatAsCurrency(code: budget.currency))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .tint(isOverBudget ? .red : .green)
            
            if isOverBudget {
                Text("Over budget by \(abs(remaining).formatAsCurrency(code: budget.currency))")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("\(remaining.formatAsCurrency(code: budget.currency)) remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isOverBudget ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}
```

---

## Utility Views

### Empty State

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
```

### Loading View

```swift
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
```

### Color Extension

```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## TODO: Customization Checklist

- [ ] Customize colors to match your brand
- [ ] Add your own SF Symbols or custom icons
- [ ] Implement dark mode support
- [ ] Add haptic feedback for interactions
- [ ] Create custom animations
- [ ] Build accessibility features (VoiceOver, Dynamic Type)
- [ ] Add localization support
- [ ] Create iPad-specific layouts
- [ ] Implement widget extensions
