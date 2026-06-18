# CareHub

Flutter (Dart) app for **sanitary pad donation and distribution tracking**, backed by **Supabase**.

## Features

| Area | Data tracked |
|------|----------------|
| Inventory | Brand, type, absorbency, disposable/reusable, color, packet size, stock, batch, expiry, location, cost |
| Donations | Donor, contact, date, quantity, type, notes |
| Beneficiaries | Unique ID, age group, school/community, optional contact (with consent) |
| Distribution | Date, recipient, quantity, brand, volunteer, location, notes |
| Schools & communities | Name, location, contact, girls served |
| Volunteers | Name, contact, role, activities |
| Stock alerts | Low stock, out of stock, expiry warnings |
| Finances | Donations, purchases, expenses, balance |
| Impact | Totals donated/distributed, girls supported, schools/communities reached |

## Setup

1. **Flutter** 3.16+ and Dart 3.11+

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. Supabase

    Create a project at [supabase.com](https://supabase.com)
    Run `supabase/migrations/001_initial_schema.sql` in the SQL editor
    Optionally run `supabase/seed_sample_data.sql` for sample rows
   Copy `.env.example` to `.env` and set `SUPABASE_URL` and `SUPABASE_ANON_KEY`

4. Run

   bash
   flutter run
   

The app requires Supabase credentials in `.env`. Use Settings → Refresh all data to reload from the database.

Architecture


lib/
  core/          theme, config, enums, QR
  data/
    models/       Dart models (fromJson / toJson)
    supabase/     Supabase client
    repositories/ CRUD per table
    services/     impact metrics, QR lookup
  features/       UI screens
  providers/      Riverpod


 Privacy

Store beneficiary **contact details only when `contactConsentGiven` is true. Prefer opaque `uniqueId` values over names in the field.
