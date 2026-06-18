-- CareHub SAMPLE DATA — run AFTER 001_initial_schema.sql
-- Paste into Supabase → SQL → New query → Run
-- Safe to re-run: deletes sample rows by fixed IDs first

-- Fixed UUIDs so foreign keys link correctly
-- pad_inventory
delete from public.pad_inventory where id = '11111111-1111-1111-1111-111111111101';
-- schools
delete from public.schools where id = '22222222-2222-2222-2222-222222222201';
-- communities
delete from public.communities where id = '33333333-3333-3333-3333-333333333301';
-- volunteers
delete from public.volunteers where id = '44444444-4444-4444-4444-444444444401';
-- beneficiaries (before schools/communities delete would fail — delete child first)
delete from public.beneficiaries where id = '55555555-5555-5555-5555-555555555501';
delete from public.donations where id = '66666666-6666-6666-6666-666666666601';
delete from public.distributions where id = '77777777-7777-7777-7777-777777777701';
delete from public.financial_records where id = '88888888-8888-8888-8888-888888888801';
delete from public.volunteer_activities where id = '99999999-9999-9999-9999-999999999901';
delete from public.stock_settings where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';

-- 1) Pad inventory
insert into public.pad_inventory (
  id, brand, type, absorbency_level, pad_category,
  color, packet_size, quantity_in_stock, batch_number,
  expiry_date, storage_location, cost_per_packet, low_stock_threshold
) values (
  '11111111-1111-1111-1111-111111111101',
  'Always',
  'Ultra thin',
  'Heavy',
  'disposable',
  'White',
  8,
  200,
  'BATCH-2026-01',
  '2027-01-15 00:00:00+00',
  'Warehouse A, Shelf 3',
  4.50,
  50
);

-- 2) School
insert into public.schools (
  id, name, location, contact_person, contact_phone, girls_served
) values (
  '22222222-2222-2222-2222-222222222201',
  'Riverside Primary',
  'Nairobi, East District',
  'Jane Wanjiku',
  '+254712345678',
  120
);

-- 3) Community
insert into public.communities (
  id, name, location, contact_person, contact_phone, girls_served
) values (
  '33333333-3333-3333-3333-333333333301',
  'Kibera Youth Group',
  'Kibera',
  'Mary Otieno',
  '+254798765432',
  45
);

-- 4) Volunteer
insert into public.volunteers (
  id, name, contact_details, role
) values (
  '44444444-4444-4444-4444-444444444401',
  'Grace Mwangi',
  'grace@example.org',
  'Distribution lead'
);

-- 5) Beneficiary (privacy: no contact unless consent)
insert into public.beneficiaries (
  id, unique_id, age_group, school_id, community_id,
  contact_details, contact_consent_given
) values (
  '55555555-5555-5555-5555-555555555501',
  'BEN-2026-00042',
  'age15to19',
  '22222222-2222-2222-2222-222222222201',
  null,
  null,
  false
);

-- 6) Donation
insert into public.donations (
  id, donor_name, contact_details, donation_date, quantity,
  donation_type, notes, inventory_item_id
) values (
  '66666666-6666-6666-6666-666666666601',
  'Local Women''s Foundation',
  'donations@lwf.org',
  now(),
  500,
  'pads',
  'Monthly pad drive',
  '11111111-1111-1111-1111-111111111101'
);

-- 7) Distribution
insert into public.distributions (
  id, distribution_date, recipient_type, recipient_name,
  school_id, quantity, brand, volunteer_id, location, notes,
  inventory_item_id
) values (
  '77777777-7777-7777-7777-777777777701',
  now(),
  'school',
  'Riverside Primary',
  '22222222-2222-2222-2222-222222222201',
  80,
  'Always',
  '44444444-4444-4444-4444-444444444401',
  'Nairobi, East District',
  'Term 1 distribution',
  '11111111-1111-1111-1111-111111111101'
);

-- 8) Financial record
insert into public.financial_records (
  id, record_type, amount, description, record_date, balance_after
) values (
  '88888888-8888-8888-8888-888888888801',
  'monetaryDonation',
  15000.00,
  'Corporate sponsor Q1',
  now(),
  15000.00
);

-- 9) Volunteer activity
insert into public.volunteer_activities (
  id, volunteer_id, description, activity_date, activity_type
) values (
  '99999999-9999-9999-9999-999999999901',
  '44444444-4444-4444-4444-444444444401',
  'Packed and delivered pads to Riverside Primary',
  now(),
  'distribution'
);

-- 10) Stock settings (optional org defaults)
insert into public.stock_settings (
  id, default_low_stock_threshold, expiry_alert_days
) values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
  50,
  90
);
