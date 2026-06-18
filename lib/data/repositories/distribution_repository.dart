import 'package:carehub_app/data/models/distribution_record.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class DistributionRepository with SupabaseTable {
  static const _table = 'distributions';
  static const _totalsView = 'distributions_totals';

  Future<List<DistributionRecord>> getAll() async {
    final rows = await db
        .from(_table)
        .select()
        .filter('deleted_at', 'is', null)
        .order('distribution_date', ascending: false);
    return mapRows(rows, DistributionRecord.fromJson);
  }

  Future<DistributionRecord> insert(DistributionRecord record) async {
    record.updatedAt = DateTime.now();
    final row = await db
        .from(_table)
        .insert(record.toJson(includeId: false))
        .select()
        .single();
    return DistributionRecord.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> softDelete(String id) async {
    await db.from(_table).update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
  }

  Future<int> totalQuantity() async {
    final row = await db.from(_totalsView).select().maybeSingle();
    if (row == null) return 0;
    final val = (row['total_quantity'] as num?) ?? 0;
    return (val).toInt();
  }
}
