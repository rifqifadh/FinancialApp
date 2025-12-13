# Investment Detail Features

This document outlines all the features implemented in the Investment Detail view.

## ✅ Implemented Features

### 1. **Maturity Management**

#### Maturity Detection Banner
- Automatically detects matured investments (Deposito, Bonds, Sukuk)
- Shows prominent banner when investment has matured
- Displays days since maturity
- One-click access to update value

#### Maturity Value Update Form
- Pre-calculates maturity value based on interest rate
- Shows profit/loss comparison
- "Use This" button to apply calculated value
- Manual override capability
- Real-time profit percentage calculation

**Files Created:**
- `FinancialApp/Presentation/InvestmentDetail/Components/MaturityBannerView.swift`
- `FinancialApp/Presentation/InvestmentDetail/Components/MaturityUpdateFormView` (embedded in MaturityBannerView.swift)

**Usage:**
```swift
// Automatically shown when investment is matured
if investment.isMatured && investment.maturityDate != nil {
    MaturityBannerView(investment: investment) {
        await viewModel.refreshAll(investmentId: investmentId)
    }
}
```

---

### 2. **Transaction Filtering & Sorting**

#### Filter Options
- **All** - Show all transactions
- **Buy** - Show only purchase transactions
- **Sell** - Show only sale transactions
- **Dividend** - Show only dividend/income transactions

#### Sort Options
- **Newest First** - Sort by date (newest → oldest)
- **Oldest First** - Sort by date (oldest → newest)
- **Highest Amount** - Sort by transaction amount (high → low)
- **Lowest Amount** - Sort by transaction amount (low → high)

#### Search Functionality
- Search by transaction type
- Search in transaction notes
- Real-time filtering
- Clear button when search is active

**Files Created:**
- `FinancialApp/Presentation/InvestmentDetail/Components/TransactionFilterView.swift`

**Features:**
- Pill-style filter and sort menus
- Search bar with clear button
- "Clear Filters" button when filters are active
- Animated filter changes
- Empty state when no results match filters

---

### 3. **Quick Actions**

Context-aware action buttons that appear based on investment type:

#### For Stocks & Equity Mutual Funds
- **Buy More** - Add more units to position
- **Sell** - Record sale of units
- **Dividend** - Record dividend payment

#### For Deposito (Time Deposits)
- **Update Value** - Update current value (shown when matured)

#### For Bonds & Sukuk
- **Record Coupon** - Record coupon payment

#### For Money Market & Fixed Income Funds
- **Buy More** - Add more units
- **Sell** - Redeem units

**Files Created:**
- `FinancialApp/Presentation/InvestmentDetail/Components/QuickActionsView.swift`

**Features:**
- Icon-based circular buttons
- Horizontal scrollable layout
- Color-coded by action type
- Pre-selects transaction type when clicked

---

### 4. **Edit & Delete Transactions**

#### Swipe Actions
- **Swipe Left** - Delete transaction (red button)
- **Swipe Right** - Edit transaction (blue button)

#### Delete Confirmation
- Confirmation dialog before deletion
- Shows transaction type and amount
- Cancel or confirm options
- Auto-recalculates investment value after deletion

#### Edit Transaction
- Opens transaction form with pre-filled data
- All fields editable
- Maintains transaction ID
- Refreshes view after update

**Files Modified:**
- `FinancialApp/Presentation/InvestmentDetail/InvestmentDetailView.swift`
- `FinancialApp/Presentation/InvestmentDetail/InvestmentDetailViewModel.swift`
- `FinancialApp/Presentation/InvestmentDetail/InvestmentTransactionFormView.swift`

**Features:**
- Swipe gestures on transaction cards
- Confirmation dialog with destructive button styling
- Sheet presentation for edit form
- Automatic value recalculation for stocks

---

## 📁 File Structure

```
FinancialApp/Presentation/InvestmentDetail/
├── InvestmentDetailView.swift (Updated)
├── InvestmentDetailViewModel.swift (Updated)
├── InvestmentTransactionFormView.swift (Updated)
├── InvestmentTransactionCard.swift
└── Components/
    ├── MaturityBannerView.swift (New)
    ├── TransactionFilterView.swift (New)
    └── QuickActionsView.swift (New)
```

---

## 🎯 User Experience Flow

### Viewing Investment Details
1. User opens investment detail
2. System checks if investment is matured
3. If matured, shows prominent banner
4. User sees header card with current value
5. Quick action buttons appear based on investment type

### Managing Matured Investments
1. User sees maturity banner
2. Clicks "Update Value"
3. System pre-calculates maturity value with interest
4. User can use calculated value or enter custom amount
5. System updates investment and refreshes view

### Adding Transactions via Quick Actions
1. User clicks quick action button (e.g., "Dividend")
2. Transaction form opens with pre-selected type
3. User enters amount and details
4. System saves and refreshes investment view
5. New transaction appears in list

### Filtering Transactions
1. User switches to "Transactions" tab
2. Sees filter bar at top
3. Selects filter (e.g., "Dividend only")
4. List updates in real-time
5. Can sort by date or amount
6. Can search by keyword

### Editing Transactions
1. User swipes right on transaction
2. Edit form opens with pre-filled data
3. User modifies fields
4. Saves changes
5. View refreshes with updated data

### Deleting Transactions
1. User swipes left on transaction
2. Red delete button appears
3. User taps delete
4. Confirmation dialog shows
5. User confirms deletion
6. Transaction removed and view updated

---

## 🎨 UI Components

### MaturityBannerView
- Accent-colored banner with border
- Exclamation icon
- Days since maturity text
- Prominent "Update Value" button
- Sheet presentation for update form

### TransactionFilterView
- Search bar with icon
- Filter dropdown menu
- Sort dropdown menu
- "Clear" button for active filters
- Compact, single-row layout

### QuickActionsView
- Horizontal scrollable container
- Circular icon buttons (50x50)
- Icon with label below
- Color-coded by action type
- Adapts to investment type

### Delete Confirmation Dialog
- Standard iOS destructive dialog
- Shows transaction details
- Red "Delete" button
- Gray "Cancel" button

---

## 🔧 Technical Implementation

### ViewModel Enhancements

```swift
// Filter & Sort State
var selectedFilter: TransactionFilter = .all
var selectedSort: TransactionSortOption = .dateNewest
var searchText: String = ""

// Computed filtered & sorted list
var filteredAndSortedTransactions: [InvestmentTransactionModel] {
    // Apply filter → search → sort
}

// Delete confirmation
var transactionToDelete: InvestmentTransactionModel?
var showingDeleteConfirmation = false

func confirmDelete(_ transaction: InvestmentTransactionModel)
func cancelDelete()
func performDelete() async
```

### Filter Types

```swift
enum TransactionFilter: String, CaseIterable {
    case all, buy, sell, dividend

    func matches(_ transaction: InvestmentTransactionModel) -> Bool
}

enum TransactionSortOption: String, CaseIterable {
    case dateNewest, dateOldest
    case amountHighest, amountLowest
}
```

### Quick Action Types

```swift
enum QuickAction: Identifiable {
    case buyMore, sell, dividend
    case updateValue, recordCoupon

    var title: String
    var icon: String
    var color: Color
}
```

---

## 📊 Performance Considerations

1. **Filtering is computed, not cached** - Recalculates on every state change
2. **Swipe actions are non-destructive** - Require confirmation
3. **Async operations** - All network calls use async/await
4. **Automatic refresh** - View refreshes after create/update/delete

---

## 🧪 Testing Checklist

- [ ] Maturity banner appears for matured deposito
- [ ] Maturity value calculated correctly
- [ ] Manual value override works
- [ ] Filter by transaction type works
- [ ] Sort by date/amount works
- [ ] Search in transactions works
- [ ] Swipe left shows delete button
- [ ] Swipe right shows edit button
- [ ] Delete confirmation shows correct details
- [ ] Delete removes transaction and updates value
- [ ] Edit opens form with correct data
- [ ] Edit saves changes correctly
- [ ] Quick actions show correct buttons for each type
- [ ] Quick action pre-selects transaction type
- [ ] Empty state shows when no transactions
- [ ] No results state shows when filter returns empty
- [ ] Clear filters button works

---

## 📱 SwiftUI Previews

### Matured Deposito Preview
A dedicated preview shows the matured deposito experience:
- Preview name: **"Matured Deposito"**
- Mock data: `InvestmentResponse.mockMaturedDeposito`
- Shows MaturityBannerView with "Matured 5 days ago" message
- Demonstrates the update value workflow
- Located in [InvestmentDetailView.swift:507-573](FinancialApp/Presentation/InvestmentDetail/InvestmentDetailView.swift#L507-L573)

**Mock Data Details:**
```swift
static let mockMaturedDeposito = InvestmentResponse(
    id: "6",
    name: "Deposito Mandiri 12 Bulan",
    type: .deposito,
    initialAmount: 50000000, // Rp 50,000,000
    currentValue: 50000000,  // Not yet updated
    purchaseDate: 12 months ago,
    maturityDate: 5 days ago,  // Matured!
    interestRate: 4.5%
)
```

## 🎨 UI/UX Improvements

### Font Size Optimization (December 2025)
- **Current Value**: Changed from `largeTitle` to `financialLarge`
- **Reason**: The `largeTitle` font was too large for the investment detail header
- **Impact**: Better visual hierarchy and more comfortable reading
- **Location**: [InvestmentDetailView.swift:172](FinancialApp/Presentation/InvestmentDetail/InvestmentDetailView.swift#L172)

---

## 🚀 Future Enhancements (Not Implemented)

These features were discussed but not implemented:

1. **Performance Charts** - Visual charts showing value over time
2. **Export Transactions** - CSV export functionality
3. **Notifications** - Maturity date reminders
4. **Batch Operations** - Select and delete multiple transactions
5. **Transaction Categories** - Custom tags for transactions
6. **Recurring Dividends** - Auto-create dividend transactions

---

## 📝 Notes

- All monetary values use `Int` type (cents/smallest unit)
- Dates use ISO8601 format for API calls
- Colors use AppTheme constants
- Spacing uses AppTheme.Spacing values
- All async operations show loading states
- Error handling with user-friendly messages
