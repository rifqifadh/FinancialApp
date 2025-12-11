# RPC Function Troubleshooting Guide

## Error: "Could not find the function public.insert_investment"

This error occurs when the RPC function signature doesn't match what the Swift code is sending.

## Root Cause

The Supabase Swift SDK wraps parameters in a specific way when calling RPC functions. The functions need to accept a single JSONB parameter instead of individual parameters.

## Solution

### Step 1: Run the Fix Script

Open your Supabase SQL Editor and run the contents of `supabase_migrations/fix_rpc_functions.sql`:

```sql
-- This will drop the old functions and create new ones with JSONB parameters
```

### Step 2: Verify the Functions Were Updated

Check that the functions exist with the correct signature:

```sql
-- Check insert_investment function
SELECT
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'insert_investment';

-- Check insert_investment_transaction function
SELECT
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'insert_investment_transaction';
```

Expected output: Both should return with `data_type = 'uuid'`

### Step 3: Test the RPC Functions Directly

Test that the functions work with JSONB parameters:

#### Test insert_investment:

```sql
SELECT public.insert_investment(
  '{"name": "Test Investment",
    "type": "Saham",
    "account_id": null,
    "initial_amount": "1000000",
    "current_value": "1000000",
    "purchase_date": "2024-12-10T00:00:00Z",
    "maturity_date": null,
    "interest_rate": null,
    "units": "100",
    "price_per_unit": "10000",
    "notes": "Test"}'::jsonb
);
```

This should return a UUID if successful.

#### Test insert_investment_transaction:

First, get an investment ID:
```sql
SELECT id FROM public.investments LIMIT 1;
```

Then test the transaction function:
```sql
SELECT public.insert_investment_transaction(
  '{"investment_id": "YOUR-INVESTMENT-ID-HERE",
    "type": "Buy",
    "units": "10",
    "price_per_unit": "10000",
    "total_amount": "100000",
    "transaction_date": "2024-12-10T00:00:00Z",
    "notes": "Test transaction"}'::jsonb
);
```

### Step 4: Rebuild Your iOS App

After updating the database functions, rebuild your app:

```bash
xcodebuild -scheme FinancialApp -configuration Debug clean build
```

## How the Fix Works

### Before (Individual Parameters)
```sql
CREATE FUNCTION insert_investment(
  name TEXT,
  type TEXT,
  account_id UUID,
  -- ... more parameters
)
```

This didn't work because Supabase Swift SDK wraps all parameters in a JSON object.

### After (JSONB Parameter)
```sql
CREATE FUNCTION insert_investment(
  params JSONB  -- Single parameter containing all fields
)
```

The Swift code now sends:
```swift
let wrappedParams = ["params": params]
client.rpc("insert_investment", params: wrappedParams)
```

Which gets received as:
```json
{
  "params": {
    "name": "Investment Name",
    "type": "Saham",
    "initial_amount": 1000000,
    ...
  }
}
```

## Debugging Tips

### 1. Check Supabase Logs

In your Supabase dashboard:
1. Go to **Logs** → **Postgres Logs**
2. Look for errors related to function calls
3. Check for authentication errors

### 2. Enable Detailed Logging in iOS

Add this to see the exact RPC call being made:

```swift
// In SupabaseManager.swift
client = SupabaseClient(
  supabaseURL: SupabaseEnv.url,
  supabaseKey: SupabaseEnv.apiKey,
  options: SupabaseClientOptions(
    global: SupabaseClientOptions.GlobalOptions(
      logger: AppLogger()  // This is already enabled
    )
  )
)
```

Then check the Xcode console for detailed logs.

### 3. Test Authentication

Make sure you're authenticated before calling the functions:

```swift
do {
  let user = try await SupabaseManager.shared.client.auth.user()
  print("Authenticated as: \(user.id)")
} catch {
  print("Not authenticated: \(error)")
}
```

### 4. Check Parameter Types

Ensure your parameter types match:

| Field | Swift Type | DB Type | JSONB Extraction |
|-------|-----------|---------|------------------|
| name | String | TEXT | `params->>'name'` |
| type | String | TEXT | `params->>'type'` |
| account_id | String? | UUID | `(params->>'account_id')::UUID` |
| initial_amount | Double | NUMERIC | `(params->>'initial_amount')::NUMERIC` |
| current_value | Double | NUMERIC | `(params->>'current_value')::NUMERIC` |
| purchase_date | String | TIMESTAMPTZ | `(params->>'purchase_date')::TIMESTAMPTZ` |
| units | Double? | NUMERIC | `(params->>'units')::NUMERIC` |
| price_per_unit | Double? | NUMERIC | `(params->>'price_per_unit')::NUMERIC` |

## Common Errors and Solutions

### Error: "Not authenticated"
**Solution:** Ensure user is logged in before making investment calls.

### Error: "Invalid input syntax for type uuid"
**Solution:** Check that `account_id` is a valid UUID string or null.

### Error: "Invalid input syntax for type numeric"
**Solution:** Ensure numeric fields (amounts, units, prices) are numbers, not strings with currency symbols.

### Error: "Invalid input syntax for type timestamp"
**Solution:** Use ISO8601 format for dates:
```swift
let formatter = ISO8601DateFormatter()
formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
let dateString = formatter.string(from: date)
```

### Error: "Investment not found" (for transactions)
**Solution:**
1. Verify the investment exists
2. Verify the investment belongs to the current user
3. Check that `investment_id` is correct

## Verification Checklist

- [ ] Ran `fix_rpc_functions.sql` in Supabase SQL Editor
- [ ] Verified functions exist with correct signature
- [ ] Tested functions directly in SQL Editor
- [ ] User is authenticated
- [ ] Cleaned and rebuilt iOS app
- [ ] Checked Supabase logs for errors
- [ ] Parameter types match expected format

## Still Having Issues?

1. **Drop and recreate everything:**
   - Run the full `supabase_migrations/investments_schema.sql` script
   - This will recreate tables, indexes, triggers, RPC functions, and RLS policies

2. **Check for schema cache issues:**
   ```sql
   -- Force schema cache refresh (Supabase does this automatically, but just in case)
   SELECT pg_catalog.pg_notify('pgrst', 'reload schema');
   ```

3. **Verify RLS policies aren't blocking:**
   ```sql
   -- Temporarily disable RLS to test (DON'T DO THIS IN PRODUCTION!)
   ALTER TABLE public.investments DISABLE ROW LEVEL SECURITY;
   -- Try your operation
   -- Then re-enable:
   ALTER TABLE public.investments ENABLE ROW LEVEL SECURITY;
   ```

## Contact Support

If none of the above solutions work, check:
1. Supabase Dashboard → Logs → Postgres Logs
2. Xcode Console output
3. Network requests in Supabase Dashboard → API

Include this information when asking for help:
- Exact error message
- Supabase log entries
- iOS console output
- The SQL function definition you're using
