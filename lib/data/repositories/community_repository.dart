import 'package:carehub_app/data/models/community.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class CommunityRepository with SupabaseTable {
  static const _table = 'communities';

  Future<List<Community>> getAll() async {
    final rows = await db.from(_table).select().order('name');
    return mapRows(rows, Community.fromJson);
  }

  Future<Community?> getById(String id) async {
    final row = await db.from(_table).select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Community.fromJson(Map<String, dynamic>.from(row));
  }
}
