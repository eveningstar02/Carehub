import 'package:carehub_app/data/models/user_settings.dart';
import 'package:carehub_app/data/models/user_profile.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSettingsRepository with SupabaseTable {
  static const _table = 'user_settings';
  static const _profilesTable = 'user_profiles';

  Future<UserSettings?> getForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final row = await db.from(_table).select().eq('user_id', user.id).maybeSingle();
    if (row == null) return null;
    return UserSettings.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<UserSettings> upsertForCurrentUser(UserSettings settings) async {
    // upsert (insert or update) and return saved row
    final row = await db.from(_table).upsert(settings.toJson(), onConflict: 'user_id').select().single();
    return UserSettings.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<void> ensureDefaultsForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final existing = await db.from(_table).select('user_id').eq('user_id', user.id).maybeSingle();
    if (existing == null) {
      await db.from(_table).insert({
        'user_id': user.id,
        'auto_sync': false,
        'analytics_enabled': true,
        'low_stock_threshold': 10,
        'expiry_alert_days': 14,
        'onboarding_seen': false,
      });
    }
  }

  Future<UserProfile?> getProfileForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final row = await db.from(_profilesTable).select().eq('id', user.id).maybeSingle();
    if (row == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<UserProfile> upsertProfile(UserProfile profile) async {
    final row = await db.from(_profilesTable).upsert(profile.toJson(), onConflict: 'id').select().single();
    return UserProfile.fromJson(Map<String, dynamic>.from(row as Map));
  }
}
