# Supabase ↔ Dart model mapping

| Supabase table | Dart model |
|----------------|------------|
| `pad_inventory` | `PadInventoryItem` |
| `donations` | `DonationRecord` |
| `schools` | `School` |
| `communities` | `Community` |
| `beneficiaries` | `Beneficiary` |
| `distributions` | `DistributionRecord` |
| `volunteers` | `Volunteer` |
| `volunteer_activities` | `VolunteerActivity` |
| `financial_records` | `FinancialRecord` |
| `stock_settings` | `StockSettings` |

Column names use `snake_case` in Postgres. Each model has `fromJson` / `toJson` in `lib/data/models/`.

## QR codes

Labels encode JSON (see `lib/core/qr/carehub_qr.dart`):

```json
{
  "v": 1,
  "t": "inventory",
  "id": "<uuid>",
  "brand": "…",
  "batch_number": "…"
}
```

Scanning fills forms from embedded fields and/or loads the record by `id` from Supabase.
