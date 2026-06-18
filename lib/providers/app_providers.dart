import 'package:carehub_app/data/repositories/distribution_repository.dart';
import 'package:carehub_app/data/repositories/donation_repository.dart';
import 'package:carehub_app/data/repositories/financial_repository.dart';
import 'package:carehub_app/data/repositories/inventory_repository.dart';
import 'package:carehub_app/data/repositories/school_repository.dart';
import 'package:carehub_app/data/repositories/volunteer_repository.dart';
import 'package:carehub_app/data/services/impact_service.dart';
import 'package:carehub_app/data/models/user_profile.dart';
import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carehub_app/data/repositories/user_settings_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());
final donationRepositoryProvider = Provider((ref) => DonationRepository());
final distributionRepositoryProvider = Provider(
  (ref) => DistributionRepository(),
);
final schoolRepositoryProvider = Provider((ref) => SchoolRepository());
final volunteerRepositoryProvider = Provider((ref) => VolunteerRepository());
final financialRepositoryProvider = Provider((ref) => FinancialRepository());
final impactServiceProvider = Provider((ref) => ImpactService());

final impactMetricsProvider = FutureProvider(
  (ref) => ref.watch(impactServiceProvider).compute(),
);

final stockAlertsProvider = FutureProvider(
  (ref) => ref.watch(inventoryRepositoryProvider).getAlerts(),
);

final inventoryListProvider = FutureProvider(
  (ref) => ref.watch(inventoryRepositoryProvider).getAll(),
);

final donationsListProvider = FutureProvider(
  (ref) => ref.watch(donationRepositoryProvider).getAll(),
);

final distributionsListProvider = FutureProvider(
  (ref) => ref.watch(distributionRepositoryProvider).getAll(),
);

final schoolsListProvider = FutureProvider(
  (ref) => ref.watch(schoolRepositoryProvider).getAll(),
);

final volunteersListProvider = FutureProvider(
  (ref) => ref.watch(volunteerRepositoryProvider).getAll(),
);

final financialListProvider = FutureProvider(
  (ref) => ref.watch(financialRepositoryProvider).getAll(),
);

final userSettingsRepositoryProvider = Provider(
  (ref) => UserSettingsRepository(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  final client = Supabase.instance.client;
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

// User profile provider - fetches from Supabase user metadata or defaults
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    throw Exception('No authenticated user');
  }

  // Try to get role from user metadata or default to contributor
  final roleStr = user.userMetadata?['role'] as String? ?? 'contributor';
  final authRole = _parseRole(roleStr);

  final profile = await ref
      .read(userSettingsRepositoryProvider)
      .getProfileForCurrentUser();

  if (profile != null) {
    // If DB row exists but role is default contributor from an older profile,
    // prefer auth metadata when it is explicitly set.
    if (profile.role == UserRole.contributor && roleStr != 'contributor') {
      return profile.copyWith(role: authRole);
    }
    return profile;
  }

  // Fallback to auth metadata if profile row is not yet available.
  return UserProfile(
    id: user.id,
    fullName: user.userMetadata?['full_name'] as String?,
    avatarUrl: user.userMetadata?['avatar_url'] as String?,
    language: user.userMetadata?['language'] as String? ?? 'en',
    role: authRole,
  );
});

// Current user role provider
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  return profile.role;
});

// Helper function to parse role string
UserRole _parseRole(String? roleStr) {
  if (roleStr == null) return UserRole.contributor;
  try {
    return UserRole.values.firstWhere((r) => r.name == roleStr);
  } catch (_) {
    return UserRole.contributor;
  }
}

// Theme mode provider to allow toggling between light and dark themes.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _prefsKey = 'themeMode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored == 'light') {
        state = ThemeMode.light;
      } else if (stored == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      // ignore errors and keep system default
      state = ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system';
      await prefs.setString(_prefsKey, value);
    } catch (_) {}
  }

  Future<void> toggleDark() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await set(next);
  }

  bool get isDark => state == ThemeMode.dark;
}
