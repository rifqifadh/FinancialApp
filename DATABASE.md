# Database Schema

This document describes the Supabase database schema for FinancialApp.

## Tables

### conversation_sessions

Manages conversation sessions between users and AI agents, tracking active agents and conversation state.

```sql
create table public.conversation_sessions (
  id uuid not null default extensions.uuid_generate_v4 (),
  conversation_id uuid not null,
  user_id uuid not null,
  agents jsonb null default '{}'::jsonb,
  last_active_agent text null,
  last_interaction timestamp with time zone null default now(),
  conversation_summary jsonb null default '[]'::jsonb,
  expires_at timestamp with time zone null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint conversation_sessions_pkey primary key (id),
  constraint conversation_sessions_conversation_id_key unique (conversation_id)
) TABLESPACE pg_default;

create index IF not exists idx_conversation_id on public.conversation_sessions using btree (conversation_id) TABLESPACE pg_default;

create index IF not exists idx_expires_at on public.conversation_sessions using btree (expires_at) TABLESPACE pg_default;
```

#### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | uuid | PRIMARY KEY, NOT NULL, DEFAULT uuid_generate_v4() | Unique identifier for the session |
| `conversation_id` | uuid | UNIQUE, NOT NULL | Reference to the conversation |
| `user_id` | uuid | NOT NULL | Reference to the user participating in the conversation |
| `agents` | jsonb | NULL, DEFAULT '{}' | JSON object storing agent configurations and state |
| `last_active_agent` | text | NULL | Text identifier of the most recently active agent |
| `last_interaction` | timestamptz | NULL, DEFAULT now() | Timestamp of the last user/agent interaction |
| `conversation_summary` | jsonb | NULL, DEFAULT '[]' | JSON array storing conversation history/summary |
| `expires_at` | timestamptz | NULL | Optional expiration timestamp for session cleanup |
| `created_at` | timestamptz | NULL, DEFAULT now() | Timestamp when the session was created |
| `updated_at` | timestamptz | NULL, DEFAULT now() | Timestamp when the session was last modified |

#### Indexes

- `conversation_sessions_pkey`: Primary key on `id`
- `conversation_sessions_conversation_id_key`: Unique constraint on `conversation_id`
- `idx_conversation_id`: B-tree index on `conversation_id` for fast lookups
- `idx_expires_at`: B-tree index on `expires_at` for efficient session cleanup queries

#### Usage Notes

- The `agents` field stores a JSON object containing agent-specific data and configurations
- The `conversation_summary` field stores an array of conversation events or summaries
- The `expires_at` field can be used to implement automatic session cleanup via scheduled tasks
- Both `created_at` and `updated_at` are automatically set but can be updated via triggers

---

### investments

Stores user investment portfolio items including stocks, bonds, mutual funds, deposits, and other investment types.

```sql
create table public.investments (
  id uuid not null default extensions.uuid_generate_v4(),
  user_id uuid not null,
  name text not null,
  type text not null,
  account_id uuid null,
  initial_amount numeric(15,2) not null,
  current_value numeric(15,2) not null,
  purchase_date timestamp with time zone not null,
  maturity_date timestamp with time zone null,
  interest_rate numeric(5,2) null,
  units numeric(15,4) null,
  price_per_unit numeric(15,2) null,
  notes text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint investments_pkey primary key (id),
  constraint investments_user_id_fkey foreign key (user_id) references auth.users(id) on delete cascade,
  constraint investments_type_check check (type in (
    'Deposito',
    'Obligasi',
    'Saham',
    'Reksa Dana Pasar Uang',
    'Reksa Dana Pendapatan Tetap',
    'Reksa Dana Campuran',
    'Reksa Dana Saham',
    'Emas',
    'Sukuk',
    'Properti',
    'Cryptocurrency',
    'Lainnya'
  ))
) tablespace pg_default;

create index if not exists idx_investments_user_id on public.investments using btree (user_id) tablespace pg_default;
create index if not exists idx_investments_type on public.investments using btree (type) tablespace pg_default;
create index if not exists idx_investments_purchase_date on public.investments using btree (purchase_date) tablespace pg_default;
create index if not exists idx_investments_maturity_date on public.investments using btree (maturity_date) tablespace pg_default;

-- Trigger to automatically update updated_at timestamp
create or replace function public.handle_investments_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger investments_updated_at
  before update on public.investments
  for each row
  execute function public.handle_investments_updated_at();
```

#### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | uuid | PRIMARY KEY, NOT NULL, DEFAULT uuid_generate_v4() | Unique identifier for the investment |
| `user_id` | uuid | FOREIGN KEY, NOT NULL | Reference to the user who owns this investment |
| `name` | text | NOT NULL | Name or description of the investment |
| `type` | text | NOT NULL, CHECK constraint | Type of investment (see constraint for valid values) |
| `account_id` | uuid | NULL | Optional reference to the account where this investment is held |
| `initial_amount` | numeric(15,2) | NOT NULL | Initial purchase amount in currency |
| `current_value` | numeric(15,2) | NOT NULL | Current market value of the investment |
| `purchase_date` | timestamptz | NOT NULL | Date when the investment was purchased |
| `maturity_date` | timestamptz | NULL | Optional maturity/expiration date for time-bound investments |
| `interest_rate` | numeric(5,2) | NULL | Annual interest rate percentage (e.g., 5.25 for 5.25%) |
| `units` | numeric(15,4) | NULL | Number of units/shares/grams owned |
| `price_per_unit` | numeric(15,2) | NULL | Price per unit at time of purchase |
| `notes` | text | NULL | Additional notes about the investment |
| `created_at` | timestamptz | NULL, DEFAULT now() | Timestamp when the record was created |
| `updated_at` | timestamptz | NULL, DEFAULT now() | Timestamp when the record was last modified |

#### Indexes

- `investments_pkey`: Primary key on `id`
- `idx_investments_user_id`: B-tree index on `user_id` for fast user-specific queries
- `idx_investments_type`: B-tree index on `type` for filtering by investment type
- `idx_investments_purchase_date`: B-tree index on `purchase_date` for date-based queries
- `idx_investments_maturity_date`: B-tree index on `maturity_date` for maturity tracking

#### Valid Investment Types

- `Deposito`: Time deposits
- `Obligasi`: Bonds
- `Saham`: Stocks
- `Reksa Dana Pasar Uang`: Money Market Mutual Funds
- `Reksa Dana Pendapatan Tetap`: Fixed Income Mutual Funds
- `Reksa Dana Campuran`: Balanced Mutual Funds
- `Reksa Dana Saham`: Equity Mutual Funds
- `Emas`: Gold
- `Sukuk`: Islamic bonds
- `Properti`: Property/Real estate
- `Cryptocurrency`: Cryptocurrency
- `Lainnya`: Other investment types

#### Usage Notes

- The `account_id` field can link to an accounts table if you want to track which financial account holds the investment
- `current_value` should be updated regularly (manually or via automated price feeds)
- Computed fields (profit, profit percentage, days held) are calculated in the application layer
- The `units` and `price_per_unit` fields are primarily used for unit-based investments like stocks and mutual funds
- The `interest_rate` field is used for fixed-income investments like deposits and bonds
- Foreign key constraint with `on delete cascade` ensures investments are deleted when user is deleted
- The `updated_at` trigger automatically updates the timestamp on any record modification

---

### investment_transactions

Tracks buy, sell, and dividend transactions for investments, providing a complete transaction history.

```sql
create table public.investment_transactions (
  id uuid not null default extensions.uuid_generate_v4(),
  investment_id uuid not null,
  type text not null,
  units numeric(15,4) not null,
  price_per_unit numeric(15,2) not null,
  total_amount numeric(15,2) not null,
  transaction_date timestamp with time zone not null,
  notes text null,
  created_at timestamp with time zone null default now(),
  constraint investment_transactions_pkey primary key (id),
  constraint investment_transactions_investment_id_fkey foreign key (investment_id) references public.investments(id) on delete cascade,
  constraint investment_transactions_type_check check (type in ('Buy', 'Sell', 'Dividend'))
) tablespace pg_default;

create index if not exists idx_investment_transactions_investment_id on public.investment_transactions using btree (investment_id) tablespace pg_default;
create index if not exists idx_investment_transactions_type on public.investment_transactions using btree (type) tablespace pg_default;
create index if not exists idx_investment_transactions_date on public.investment_transactions using btree (transaction_date) tablespace pg_default;
```

#### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | uuid | PRIMARY KEY, NOT NULL, DEFAULT uuid_generate_v4() | Unique identifier for the transaction |
| `investment_id` | uuid | FOREIGN KEY, NOT NULL | Reference to the parent investment |
| `type` | text | NOT NULL, CHECK constraint | Type of transaction: 'Buy', 'Sell', or 'Dividend' |
| `units` | numeric(15,4) | NOT NULL | Number of units involved in the transaction |
| `price_per_unit` | numeric(15,2) | NOT NULL | Price per unit at the time of transaction |
| `total_amount` | numeric(15,2) | NOT NULL | Total transaction amount (units × price_per_unit) |
| `transaction_date` | timestamptz | NOT NULL | Date and time when the transaction occurred |
| `notes` | text | NULL | Additional notes about the transaction |
| `created_at` | timestamptz | NULL, DEFAULT now() | Timestamp when the record was created |

#### Indexes

- `investment_transactions_pkey`: Primary key on `id`
- `idx_investment_transactions_investment_id`: B-tree index on `investment_id` for fast investment-specific queries
- `idx_investment_transactions_type`: B-tree index on `type` for filtering by transaction type
- `idx_investment_transactions_date`: B-tree index on `transaction_date` for chronological queries

#### Transaction Types

- `Buy`: Purchase of investment units (cash outflow)
- `Sell`: Sale of investment units (cash inflow)
- `Dividend`: Dividend or interest income received (cash inflow)

#### Usage Notes

- Foreign key constraint with `on delete cascade` ensures transactions are deleted when parent investment is deleted
- The `total_amount` should always equal `units × price_per_unit` (validated at application layer)
- Transaction history allows for accurate cost basis calculations and performance tracking
- For `Dividend` transactions, `units` represents the number of shares that generated the dividend
- All monetary amounts are stored as numeric(15,2) for precision in financial calculations
