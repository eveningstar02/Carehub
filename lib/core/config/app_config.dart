import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase and app settings loaded from `.env` (see `.env.example`).
class AppConfig {
  AppConfig._();

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const int defaultLowStockThreshold = 50;
  static const int defaultExpiryAlertDays = 90;
}
