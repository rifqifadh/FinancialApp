# Investment Detail - Quick Reference

## How to Use the New Features

### 1. Update Matured Investment Value

**When:** Your deposito, bond, or sukuk has reached maturity date

**Steps:**
1. Open the investment
2. Look for the blue banner at the top that says "Investment Matured"
3. Tap "Update Value" button
4. Review the calculated maturity value (auto-calculated with interest rate)
5. Tap "Use This" to apply calculated value, or enter a custom amount
6. Tap "Update" to save

**Example:**
- Initial: Rp 10,000,000
- Interest Rate: 5% p.a.
- Period: 180 days
- Calculated: Rp 10,246,575 (approximate)

---

### 2. Filter & Search Transactions

**Filter by Type:**
1. Go to "Transactions" tab
2. Tap the filter dropdown (shows "All" by default)
3. Select: All, Buy, Sell, or Dividend
4. List updates instantly

**Sort Transactions:**
1. Go to "Transactions" tab
2. Tap the "Sort" dropdown
3. Select: Newest First, Oldest First, Highest Amount, or Lowest Amount

**Search:**
1. Type in the search bar
2. Searches in transaction type and notes
3. Tap X to clear

**Clear All Filters:**
- Tap "Clear" button (appears when filters are active)

---

### 3. Quick Actions for Different Investment Types

**Stocks & Equity Mutual Funds:**
- 🟢 **Buy More** - Record additional purchase
- 🔴 **Sell** - Record sale of shares
- 💰 **Dividend** - Record dividend received

**Deposito (when matured):**
- 🔄 **Update Value** - Update to maturity value

**Bonds & Sukuk:**
- 📄 **Record Coupon** - Record coupon payment received

**Money Market & Fixed Income Funds:**
- 🟢 **Buy More** - Add more units
- 🔴 **Sell** - Redeem units

---

### 4. Edit Transaction

**Method 1 - Swipe Right:**
1. Swipe right on any transaction
2. Tap the blue "Edit" button
3. Modify fields as needed
4. Tap "Update"

**Method 2 - Tap:**
1. Tap on the transaction card
2. Edit form opens
3. Modify and save

---

### 5. Delete Transaction

1. Swipe left on any transaction
2. Tap the red "Delete" button
3. Confirm deletion in dialog
4. Transaction removed
5. Investment value auto-recalculates (for stocks)

**Warning:** This action cannot be undone!

---

## UI Components Explained

### Maturity Banner
```
┌────────────────────────────────────┐
│ ⚠️  Investment Matured             │
│     Matured 5 days ago             │
│                                    │
│  [🔄 Update Value]                 │
└────────────────────────────────────┘
```

### Filter Bar
```
┌────────────────────────────────────┐
│ 🔍 Search transactions...     [×]  │
│                                    │
│ [All ▼]  [Sort ▼]     [Clear]      │
└────────────────────────────────────┘
```

### Quick Actions
```
┌────────────────────────────────────┐
│ Quick Actions                      │
│                                    │
│  🟢      🔴      💰                 │
│  Buy     Sell    Dividend          │
│  More                              │
└────────────────────────────────────┘
```

### Transaction Card (with swipe)
```
Swipe Right →  [Edit] [CARD] [Delete] ← Swipe Left
```

---

## Common Workflows

### Recording a Stock Dividend
1. Open stock investment
2. Tap "Dividend" quick action
3. Enter number of shares
4. Enter dividend per share
5. Total auto-calculates
6. Add notes (optional)
7. Tap "Add"

### Selling Stocks
1. Tap "Sell" quick action
2. Enter units to sell
3. Enter sell price per unit
4. Review total amount
5. Set transaction date
6. Tap "Add"
7. Investment value auto-updates

### Monthly Review
1. Go to "Transactions" tab
2. Tap "Sort" → "Newest First"
3. Review recent transactions
4. Use search to find specific transactions
5. Edit any incorrect entries
6. Delete duplicates if any

### Cleaning Up Transactions
1. Filter by transaction type
2. Review filtered list
3. Swipe left on incorrect transactions
4. Confirm deletions
5. Clear filter to see all remaining transactions

---

## Tips & Tricks

**Tip 1: Bulk Review**
- Use filters to review all dividends received
- Check if any are missing
- Add missing dividends via quick action

**Tip 2: Quick Edit**
- Made a typo? Swipe right to edit immediately
- No need to delete and recreate

**Tip 3: Maturity Planning**
- Check "Days to Maturity" in investment details
- When it matures, banner appears automatically
- Update value on maturity date for accurate tracking

**Tip 4: Search Power**
- Search works on notes too
- Add descriptive notes to transactions
- Example: "Q1 2024 dividend" - searchable by "Q1" or "2024"

**Tip 5: Accurate Records**
- For stocks: Record every buy/sell/dividend
- System calculates average buy price automatically
- Calculates unrealized vs realized profit

---

## Keyboard Shortcuts (if applicable)

- **Tab** - Move between fields in forms
- **Escape** - Close sheets/dialogs
- **Return** - Submit forms (when valid)

---

## Troubleshooting

**Problem: Can't see maturity banner**
- Solution: Check if investment has maturity date set
- Solution: Check if maturity date has passed

**Problem: Filter shows no results**
- Solution: Check if transactions exist for that type
- Solution: Tap "Clear" to reset filters

**Problem: Delete not working**
- Solution: Confirm deletion in dialog
- Solution: Check internet connection

**Problem: Value not updating after delete**
- Solution: Pull down to refresh
- Solution: Go back and re-open investment

**Problem: Quick actions not showing**
- Solution: Quick actions are type-specific
- Solution: Some investment types don't have quick actions

---

## Data Safety

**Automatic Backups:**
- All data synced to Supabase
- Real-time synchronization
- Pull to refresh to get latest data

**Delete Safety:**
- Confirmation required for all deletions
- Shows transaction details before delete
- Cannot be undone after confirmation

**Data Validation:**
- Amount must be positive
- Units must be valid numbers
- Dates must be valid
- Required fields enforced

---

## Performance Notes

**Smooth Operation:**
- Filters and sorts happen instantly (client-side)
- Network calls only for create/update/delete
- Optimistic updates for better UX

**Loading States:**
- Spinner shows during network operations
- Pull-to-refresh for manual sync
- Error messages if operation fails

---

## Accessibility

- All buttons have labels
- Icons have alt text
- Color-blind friendly (not color-only indicators)
- Swipe actions have haptic feedback
- Large touch targets

---

## Need Help?

If something doesn't work as expected:
1. Pull down to refresh
2. Go back and re-open the view
3. Check internet connection
4. Check Supabase dashboard logs
5. Refer to [TROUBLESHOOTING_RPC.md](TROUBLESHOOTING_RPC.md)
