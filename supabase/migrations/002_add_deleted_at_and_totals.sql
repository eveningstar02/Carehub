-- Add soft-delete (deleted_at) to main data tables and create totals views

alter table if exists public.volunteers add column if not exists deleted_at timestamptz;
alter table if exists public.volunteer_activities add column if not exists deleted_at timestamptz;
alter table if exists public.donations add column if not exists deleted_at timestamptz;
alter table if exists public.distributions add column if not exists deleted_at timestamptz;
alter table if exists public.financial_records add column if not exists deleted_at timestamptz;
alter table if exists public.pad_inventory add column if not exists deleted_at timestamptz;
alter table if exists public.schools add column if not exists deleted_at timestamptz;
alter table if exists public.communities add column if not exists deleted_at timestamptz;
alter table if exists public.beneficiaries add column if not exists deleted_at timestamptz;

-- Create convenient summary views for server-side totals
create or replace view public.distributions_totals as
select coalesce(sum(quantity), 0) as total_quantity
from public.distributions
where deleted_at is null;

create or replace view public.financial_totals as
select coalesce(sum(amount), 0) as total_amount
from public.financial_records
where deleted_at is null;
