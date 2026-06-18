import 'package:carehub_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => AppConfig.hasSupabase;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    if (_initialized || !isConfigured) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }
}
