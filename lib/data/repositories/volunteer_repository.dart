import 'package:carehub_app/data/models/volunteer.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class VolunteerRepository with SupabaseTable {
  static const _table = 'volunteers';
  static const _activitiesTable = 'volunteer_activities';

  Future<List<Volunteer>> getAll() async {
    final rows = await db.from(_table).select().filter('deleted_at', 'is', null).order('name');
    return mapRows(rows, Volunteer.fromJson);
  }

  Future<Volunteer?> getById(String id) async {
    final row = await db.from(_table).select().eq('id', id).filter('deleted_at', 'is', null).maybeSingle();
    if (row == null) return null;
    return Volunteer.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Volunteer> insert(Volunteer volunteer) async {
    volunteer.updatedAt = DateTime.now();
    final row = await db
        .from(_table)
        .insert(volunteer.toJson(includeId: false))
        .select()
        .single();
    return Volunteer.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> softDelete(String id) async {
    await db.from(_table).update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
  }

  Future<List<VolunteerActivity>> activitiesForVolunteer(
    String volunteerId,
  ) async {
    final rows = await db
        .from(_activitiesTable)
        .select()
        .eq('volunteer_id', volunteerId)
        .filter('deleted_at', 'is', null)
        .order('activity_date', ascending: false);
    return mapRows(rows, VolunteerActivity.fromJson);
  }

  Future<VolunteerActivity> insertActivity(VolunteerActivity activity) async {
    activity.updatedAt = DateTime.now();
    final row = await db
        .from(_activitiesTable)
        .insert(activity.toJson(includeId: false))
        .select()
        .single();
    return VolunteerActivity.fromJson(Map<String, dynamic>.from(row));
  }
}
