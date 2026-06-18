import 'package:carehub_app/data/models/school.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class SchoolRepository with SupabaseTable {
  static const _table = 'schools';

  Future<List<School>> getAll() async {
    final rows = await db.from(_table).select().order('name');
    return mapRows(rows, School.fromJson);
  }

  Future<School?> getById(String id) async {
    final row = await db.from(_table).select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return School.fromJson(Map<String, dynamic>.from(row));
  }

  Future<School> insert(School school) async {
    school.updatedAt = DateTime.now();
    final row = await db
        .from(_table)
        .insert(school.toJson(includeId: false))
        .select()
        .single();
    return School.fromJson(Map<String, dynamic>.from(row));
  }
}
