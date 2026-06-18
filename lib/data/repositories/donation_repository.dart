import 'package:carehub_app/data/models/donation_record.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class DonationRepository with SupabaseTable {
  static const _table = 'donations';

  Future<List<DonationRecord>> getAll() async {
    final rows =
        await db.from(_table).select().order('donation_date', ascending: false);
    return mapRows(rows, DonationRecord.fromJson);
  }

  Future<DonationRecord> insert(DonationRecord record) async {
    record.updatedAt = DateTime.now();
    final row = await db
        .from(_table)
        .insert(record.toJson(includeId: false))
        .select()
        .single();
    return DonationRecord.fromJson(Map<String, dynamic>.from(row));
  }
}
