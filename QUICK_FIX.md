# Quick Fix for RPC Function Error

## The Error
```
Could not find the function public.insert_investment(current_value, initial_amount, maturity_date, name, purchase_date, type) in the schema cache
```

## The Solution (3 Steps)

### 1. Run the Fix Script in Supabase

Open **Supabase Dashboard** → **SQL Editor** → **New Query**

Copy and paste the entire contents of: `supabase_migrations/fix_rpc_functions.sql`

Click **Run**

### 2. Test the Functions

Run this test in SQL Editor:

```sql
SELECT public.insert_investment(
  '{"name": "Test",
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

If this returns a UUID, you're good!

### 3. Rebuild Your iOS App

```bash
xcodebuild -scheme FinancialApp -configuration Debug clean build
```

Or in Xcode: **Product** → **Clean Build Folder** (Shift+Cmd+K), then **Product** → **Build** (Cmd+B)

## Done!

Your investment feature should now work. Try creating an investment in the app.

## Still Not Working?

See [TROUBLESHOOTING_RPC.md](TROUBLESHOOTING_RPC.md) for detailed debugging steps.
