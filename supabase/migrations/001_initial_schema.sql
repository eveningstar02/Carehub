-- CareHub Supabase schema (matches lib/data/models + sync_mapper.dart)
-- Run in Supabase SQL Editor or: supabase db push

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
-- Ensure gen_random_uuid() is available
create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- pad_inventory  ↔  PadInventoryItem
-- ---------------------------------------------------------------------------
create table if not exists public.pad_inventory (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  type text not null,
  absorbency_level text not null,
  pad_category text not null
    check (pad_category in ('disposable', 'reusable')),
  color text,
  packet_size integer not null default 1 check (packet_size > 0),
  quantity_in_stock integer not null default 0 check (quantity_in_stock >= 0),
  batch_number text,
  expiry_date timestamptz,
  storage_location text,
  cost_per_packet numeric(12, 2),
  low_stock_threshold integer not null default 50 check (low_stock_threshold >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_pad_inventory_updated_at
  on public.pad_inventory (updated_at desc);
create index if not exists idx_pad_inventory_batch
  on public.pad_inventory (batch_number) where batch_number is not null;

-- ---------------------------------------------------------------------------
-- schools  ↔  School
-- ---------------------------------------------------------------------------
create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  contact_person text,
  contact_phone text,
  girls_served integer not null default 0 check (girls_served >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_schools_name on public.schools (name);
create index if not exists idx_schools_updated_at on public.schools (updated_at desc);

-- ---------------------------------------------------------------------------
-- communities  ↔  Community
-- ---------------------------------------------------------------------------
create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  contact_person text,
  contact_phone text,
  girls_served integer not null default 0 check (girls_served >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_communities_name on public.communities (name);
create index if not exists idx_communities_updated_at on public.communities (updated_at desc);

-- ---------------------------------------------------------------------------
-- beneficiaries  ↔  Beneficiary
-- ---------------------------------------------------------------------------
create table if not exists public.beneficiaries (
  id uuid primary key default gen_random_uuid(),
  unique_id text not null unique,
  age_group text not null
    check (age_group in ('under10', 'age10to14', 'age15to19', 'over19', 'unknown')),
  school_id uuid references public.schools (id) on delete set null,
  community_id uuid references public.communities (id) on delete set null,
  contact_details text,
  contact_consent_given boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint beneficiaries_contact_requires_consent
    check (contact_consent_given = true or contact_details is null)
);

create index if not exists idx_beneficiaries_unique_id on public.beneficiaries (unique_id);
create index if not exists idx_beneficiaries_updated_at on public.beneficiaries (updated_at desc);

-- ---------------------------------------------------------------------------
-- volunteers  ↔  Volunteer
-- ---------------------------------------------------------------------------
create table if not exists public.volunteers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_details text,
  role text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_volunteers_updated_at on public.volunteers (updated_at desc);

-- ---------------------------------------------------------------------------
-- volunteer_activities  ↔  VolunteerActivity
-- ---------------------------------------------------------------------------
create table if not exists public.volunteer_activities (
  id uuid primary key default gen_random_uuid(),
  volunteer_id uuid not null references public.volunteers (id) on delete cascade,
  description text not null,
  activity_date timestamptz not null,
  activity_type text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_volunteer_activities_volunteer
  on public.volunteer_activities (volunteer_id);
create index if not exists idx_volunteer_activities_updated_at
  on public.volunteer_activities (updated_at desc);

-- ---------------------------------------------------------------------------
-- donations  ↔  DonationRecord
-- ---------------------------------------------------------------------------
create table if not exists public.donations (
  id uuid primary key default gen_random_uuid(),
  donor_name text not null,
  contact_details text,
  donation_date timestamptz not null,
  quantity integer not null default 0 check (quantity >= 0),
  donation_type text not null
    check (donation_type in ('pads', 'monetary', 'mixed', 'other')),
  notes text,
  inventory_item_id uuid references public.pad_inventory (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_donations_date on public.donations (donation_date desc);
create index if not exists idx_donations_updated_at on public.donations (updated_at desc);

-- ---------------------------------------------------------------------------
-- distributions  ↔  DistributionRecord
-- ---------------------------------------------------------------------------
create table if not exists public.distributions (
  id uuid primary key default gen_random_uuid(),
  distribution_date timestamptz not null,
  recipient_type text not null
    check (recipient_type in ('school', 'beneficiary', 'community')),
  recipient_name text,
  school_id uuid references public.schools (id) on delete set null,
  beneficiary_id uuid references public.beneficiaries (id) on delete set null,
  community_id uuid references public.communities (id) on delete set null,
  quantity integer not null default 0 check (quantity >= 0),
  brand text,
  volunteer_id uuid references public.volunteers (id) on delete set null,
  location text,
  notes text,
  inventory_item_id uuid references public.pad_inventory (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_distributions_date on public.distributions (distribution_date desc);
create index if not exists idx_distributions_updated_at on public.distributions (updated_at desc);

-- ---------------------------------------------------------------------------
-- financial_records  ↔  FinancialRecord
-- ---------------------------------------------------------------------------
create table if not exists public.financial_records (
  id uuid primary key default gen_random_uuid(),
  record_type text not null
    check (record_type in ('monetaryDonation', 'purchase', 'expense')),
  amount numeric(14, 2) not null check (amount >= 0),
  description text,
  receipt_url text,
  record_date timestamptz not null,
  balance_after numeric(14, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_financial_records_date on public.financial_records (record_date desc);
create index if not exists idx_financial_records_updated_at on public.financial_records (updated_at desc);

-- ---------------------------------------------------------------------------
-- stock_settings (org defaults; optional sync — local Isar fallback)
-- ---------------------------------------------------------------------------
create table if not exists public.stock_settings (
  id uuid primary key default gen_random_uuid(),
  default_low_stock_threshold integer not null default 50 check (default_low_stock_threshold >= 0),
  expiry_alert_days integer not null default 90 check (expiry_alert_days > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- user profiles & settings for per-user preferences
-- ---------------------------------------------------------------------------
create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  provider text,
  full_name text,
  avatar_url text,
  language text default 'en',
  role text default 'contributor'
    check (role in ('admin', 'donor', 'contributor')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  auto_sync boolean default false,
  analytics_enabled boolean default true,
  low_stock_threshold integer default 10,
  expiry_alert_days integer default 14,
  onboarding_seen boolean default false,
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- updated_at triggers (ensure updated_at is set)
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'pad_inventory', 'schools', 'communities', 'beneficiaries',
    'volunteers', 'volunteer_activities', 'donations', 'distributions',
    'financial_records', 'stock_settings', 'user_profiles', 'user_settings'
  ]
  loop
    execute format($f$
      drop trigger if exists trg_%1$s_updated_at on public.%1$s;
      create trigger trg_%1$s_updated_at
        before update on public.%1$s
        for each row execute function public.set_updated_at();
    $f$, t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Row Level Security (customize for your auth model)
-- ---------------------------------------------------------------------------
alter table public.pad_inventory enable row level security;
alter table public.schools enable row level security;
alter table public.communities enable row level security;
alter table public.beneficiaries enable row level security;
alter table public.volunteers enable row level security;
alter table public.volunteer_activities enable row level security;
alter table public.donations enable row level security;
alter table public.distributions enable row level security;
alter table public.financial_records enable row level security;
alter table public.stock_settings enable row level security;
alter table public.user_profiles enable row level security;
alter table public.user_settings enable row level security;

-- Authenticated users (replace with org-scoped policies in production)
do $$
declare
  tbl text;
begin
  foreach tbl in array array[
    'pad_inventory', 'schools', 'communities', 'beneficiaries',
    'volunteers', 'volunteer_activities', 'donations', 'distributions',
    'financial_records', 'stock_settings'
  ]
  loop
    execute format(
      'drop policy if exists authenticated_all on public.%I; create policy authenticated_all on public.%I for all to authenticated using (true) with check (true);',
      tbl, tbl
    );
  end loop;
end $$;

-- Restrict user_profiles and user_settings to their owner only
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY profiles_owner ON public.user_profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY settings_owner ON public.user_settings
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Create trigger/function to initialize user profile & settings on auth signup
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, provider, full_name, avatar_url, role)
    VALUES (
      NEW.id,
      NEW.email,
      NEW.raw_user_meta_data->>'provider',
      NEW.user_metadata->>'full_name',
      NEW.user_metadata->>'avatar_url',
      COALESCE(NEW.user_metadata->>'role', 'contributor')
    )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Trigger on auth.users
CREATE TRIGGER on_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_auth_user();

