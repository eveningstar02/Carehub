import 'package:carehub_app/data/models/financial_record.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class FinancialRepository with SupabaseTable {
  static const _table = 'financial_records';
  static const _totalsView = 'financial_totals';

  Future<List<FinancialRecord>> getAll() async {
    final rows =
        await db.from(_table).select().order('record_date', ascending: false);
    return mapRows(rows, FinancialRecord.fromJson);
  }

  Future<FinancialRecord> insert(FinancialRecord record) async {
    record.updatedAt = DateTime.now();
    final row = await db
        .from(_table)
        .insert(record.toJson(includeId: false))
        .select()
        .single();
    return FinancialRecord.fromJson(Map<String, dynamic>.from(row));
  }

  Future<double> totalAmount() async {
    final row = await db.from(_totalsView).select().maybeSingle();
    if (row == null) return 0.0;
    final val = (row['total_amount'] as num?) ?? 0;
    return (val).toDouble();
  }
}
