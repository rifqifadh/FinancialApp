# Investment Feature Database Integration Setup

This guide walks you through setting up the investment feature database integration with Supabase.

## Prerequisites

- Active Supabase project
- Supabase credentials configured in your iOS app
- Admin access to your Supabase SQL Editor

## Setup Steps

### 1. Run the Database Migration

#### Option A: Fresh Installation (Recommended)

1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy the entire contents of `supabase_migrations/investments_schema.sql`
5. Paste into the SQL Editor
6. Click **Run** to execute the migration

#### Option B: Update Existing Installation (If you already ran the old migration)

1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy the entire contents of `supabase_migrations/fix_rpc_functions.sql`
5. Paste into the SQL Editor
6. Click **Run** to execute the fix

This will create/update:
- `investments` table
- `investment_transactions` table
- All necessary indexes
- Auto-update triggers
- RPC functions with JSONB parameters (IMPORTANT!)
- Row Level Security (RLS) policies

### 2. Verify Database Tables

After running the migration, verify the tables were created:

```sql
-- Check investments table
SELECT * FROM public.investments LIMIT 1;

-- Check investment_transactions table
SELECT * FROM public.investment_transactions LIMIT 1;

-- Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('investments', 'investment_transactions');
```

Expected output: Both tables should have `rowsecurity = true`

### 3. Test RPC Functions

Test that the RPC functions work correctly:

```sql
-- Test insert_investment (should fail if not authenticated)
SELECT public.insert_investment(
  name := 'Test Investment',
  type := 'Saham',
  account_id := NULL,
  initial_amount := 1000000,
  current_value := 1000000,
  purchase_date := NOW(),
  maturity_date := NULL,
  interest_rate := NULL,
  units := 100,
  price_per_unit := 10000,
  notes := 'Test investment'
);

-- Test get_user_investments (should return empty array if not authenticated)
SELECT * FROM public.get_user_investments();
```

### 4. Update Your iOS App

The following files have already been updated to use live Supabase calls:

- ✅ `InvestmentService.swift` - Updated to use Supabase
- ✅ `InvestmentTransactionService.swift` - Updated to use Supabase

No additional code changes are needed!

### 5. Test the Integration

#### Test Authentication
Make sure you're authenticated before testing:

```swift
// Verify authentication
let user = try await SupabaseManager.shared.client.auth.user()
print("Authenticated as: \(user.email ?? "unknown")")
```

#### Test Creating an Investment

1. Open the app
2. Navigate to the Investments screen
3. Tap the "+" button
4. Fill in the investment details
5. Save

Check Supabase to verify the record was created:

```sql
SELECT * FROM public.investments ORDER BY created_at DESC LIMIT 5;
```

#### Test Fetching Investments

1. Pull to refresh on the Investments screen
2. Verify that your investments appear
3. Check console logs for any errors

#### Test Creating Transactions

1. Tap on an investment to view details
2. Tap "Add Transaction"
3. Fill in transaction details (Buy/Sell/Dividend)
4. Save

Verify in Supabase:

```sql
SELECT * FROM public.investment_transactions
ORDER BY created_at DESC LIMIT 5;
```

## Database Schema Overview

### Investments Table

Key fields:
- `id`: UUID primary key
- `user_id`: Links to authenticated user
- `name`: Investment name
- `type`: Investment type (12 supported types)
- `account_id`: Optional link to accounts table
- `initial_amount`: Initial investment amount
- `current_value`: Current market value
- `purchase_date`: When investment was made
- `maturity_date`: Optional maturity date
- `interest_rate`: Optional interest rate
- `units`: Number of units/shares
- `price_per_unit`: Price per unit
- `notes`: Additional notes

### Investment Transactions Table

Key fields:
- `id`: UUID primary key
- `investment_id`: Links to parent investment
- `type`: Buy, Sell, or Dividend
- `units`: Transaction units
- `price_per_unit`: Transaction price
- `total_amount`: Total transaction value
- `transaction_date`: When transaction occurred
- `notes`: Additional notes

## Security Features

### Row Level Security (RLS)

All tables have RLS enabled with the following policies:

**Investments:**
- ✅ Users can only view their own investments
- ✅ Users can only create investments for themselves
- ✅ Users can only update their own investments
- ✅ Users can only delete their own investments

**Investment Transactions:**
- ✅ Users can only view transactions for their own investments
- ✅ Users can only create transactions for their own investments
- ✅ Users can only update transactions for their own investments
- ✅ Users can only delete transactions for their own investments

### Data Validation

**Server-side validation:**
- Investment types are restricted to predefined values
- Transaction types are restricted to Buy/Sell/Dividend
- Foreign key constraints ensure referential integrity
- NOT NULL constraints on required fields

**Client-side validation:**
- Handled in SwiftUI forms
- Type-safe enums prevent invalid types
- Codable conformance ensures proper serialization

## RPC Functions

### `insert_investment`

Creates a new investment for the authenticated user.

**Parameters:**
- All investment fields except `id`, `user_id`, `created_at`, `updated_at`

**Returns:** UUID of newly created investment

**Security:** Automatically sets `user_id` to current authenticated user

### `insert_investment_transaction`

Creates a new transaction for an investment.

**Parameters:**
- All transaction fields except `id`, `created_at`

**Returns:** UUID of newly created transaction

**Security:**
- Verifies investment exists
- Verifies investment belongs to current user
- Prevents unauthorized transaction creation

### `get_user_investments`

Fetches all investments for the authenticated user with account names (if linked).

**Parameters:** None (uses authenticated user ID)

**Returns:** Array of investments with joined account data

**Security:** Only returns investments owned by current user

## Troubleshooting

### Issue: "Not authenticated" error

**Solution:** Ensure user is logged in before making investment calls:

```swift
guard let user = try? await SupabaseManager.shared.client.auth.user() else {
    print("User not authenticated")
    return
}
```

### Issue: "Permission denied" error

**Solution:** Verify RLS policies are correctly set:

```sql
-- Check policies on investments table
SELECT * FROM pg_policies
WHERE tablename = 'investments';

-- Check policies on investment_transactions table
SELECT * FROM pg_policies
WHERE tablename = 'investment_transactions';
```

### Issue: Type validation error

**Solution:** Ensure investment/transaction types match exactly:

Valid investment types:
- 'Deposito', 'Obligasi', 'Saham', 'Reksa Dana Pasar Uang', etc.

Valid transaction types:
- 'Buy', 'Sell', 'Dividend'

### Issue: Numeric precision errors

**Solution:** All monetary amounts are stored as `numeric(15,2)`:
- 15 total digits
- 2 decimal places
- Sufficient for values up to 9,999,999,999,999.99

### Issue: Date format errors

**Solution:** Always use ISO8601 format with timezone:
```swift
let formatter = ISO8601DateFormatter()
formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
let dateString = formatter.string(from: date)
```

## Data Migration (Optional)

If you have existing mock data you want to migrate:

```sql
-- Example: Migrate mock data to production tables
INSERT INTO public.investments (
  user_id, name, type, initial_amount, current_value, purchase_date
) VALUES (
  auth.uid(), -- Current user
  'BCA Deposito 6 Bulan',
  'Deposito',
  10000000,
  10250000,
  NOW() - INTERVAL '3 months'
);
```

## Monitoring and Maintenance

### Check Database Health

```sql
-- View investment count by type
SELECT type, COUNT(*) as count
FROM public.investments
GROUP BY type
ORDER BY count DESC;

-- View transaction count by type
SELECT type, COUNT(*) as count
FROM public.investment_transactions
GROUP BY type
ORDER BY count DESC;

-- View largest investments
SELECT name, type, current_value
FROM public.investments
ORDER BY current_value DESC
LIMIT 10;
```

### Performance Monitoring

```sql
-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE tablename IN ('investments', 'investment_transactions')
ORDER BY idx_scan DESC;
```

### Cleanup Old Data (if needed)

```sql
-- Archive investments older than 10 years
-- (Adjust retention policy as needed)
DELETE FROM public.investments
WHERE purchase_date < NOW() - INTERVAL '10 years';
```

## Next Steps

1. ✅ Run the database migration
2. ✅ Verify tables and RLS policies
3. ✅ Test RPC functions
4. ✅ Build and run your iOS app
5. ✅ Create test investments and transactions
6. ✅ Monitor database for errors
7. 🎯 Consider adding analytics and reporting features
8. 🎯 Consider implementing automated price updates
9. 🎯 Consider adding portfolio performance calculations

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Supabase logs in your dashboard
3. Check iOS console logs for client-side errors
4. Review the [DATABASE.md](DATABASE.md) for schema details

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase-community/supabase-swift)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Functions](https://www.postgresql.org/docs/current/sql-createfunction.html)
