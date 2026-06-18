import 'package:carehub_app/data/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared Supabase access helpers for repositories.
mixin SupabaseTable {
  SupabaseClient get db {
    if (!SupabaseService.isConfigured) {
      throw StateError(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env',
      );
    }
    return SupabaseService.client;
  }

  List<T> mapRows<T>(
    List<dynamic> rows,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return rows
        .map((r) => fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
  }
}
