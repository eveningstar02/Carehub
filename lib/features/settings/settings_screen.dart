import 'package:carehub_app/core/config/app_config.dart';
import 'package:carehub_app/data/supabase/supabase_service.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // preference keys
  static const _kAutoSync = 'autoSync';
  static const _kAnalytics = 'analyticsEnabled';
  static const _kOnboarding = 'onboardingSeen';
  static const _kLanguage = 'language';
  static const _kLowStock = 'lowStockThreshold';
  static const _kExpiryDays = 'expiryAlertDays';

  bool _loading = true;
  bool _autoSync = false;
  bool _analytics = true;
  bool _onboardingSeen = false;
  String _language = 'en';
  int _lowStock = AppConfig.defaultLowStockThreshold;
  int _expiryDays = AppConfig.defaultExpiryAlertDays;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSync = prefs.getBool(_kAutoSync) ?? false;
      _analytics = prefs.getBool(_kAnalytics) ?? true;
      _onboardingSeen = prefs.getBool(_kOnboarding) ?? false;
      _language = prefs.getString(_kLanguage) ?? 'en';
      _lowStock = prefs.getInt(_kLowStock) ?? AppConfig.defaultLowStockThreshold;
      _expiryDays = prefs.getInt(_kExpiryDays) ?? AppConfig.defaultExpiryAlertDays;
      _loading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  void _refreshAll() {
    ref.invalidate(impactMetricsProvider);
    ref.invalidate(stockAlertsProvider);
    ref.invalidate(inventoryListProvider);
    ref.invalidate(donationsListProvider);
    ref.invalidate(distributionsListProvider);
    ref.invalidate(schoolsListProvider);
    ref.invalidate(volunteersListProvider);
    ref.invalidate(financialListProvider);
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    // authStateProvider will update and show login
  }

  Future<void> _resetDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAutoSync);
    await prefs.remove(_kAnalytics);
    await prefs.remove(_kOnboarding);
    await prefs.remove(_kLanguage);
    await prefs.remove(_kLowStock);
    await prefs.remove(_kExpiryDays);

    setState(() {
      _autoSync = false;
      _analytics = true;
      _onboardingSeen = false;
      _language = 'en';
      _lowStock = AppConfig.defaultLowStockThreshold;
      _expiryDays = AppConfig.defaultExpiryAlertDays;
    });

    // Optionally refresh data
    _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final supabaseOk = SupabaseService.isConfigured;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Account
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(user?.email ?? 'Not signed in'),
                    subtitle: Text(user != null ? 'Signed in' : 'No account'),
                    trailing: user != null
                        ? TextButton(
                            onPressed: _signOut,
                            child: const Text('Sign out'),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Supabase
                Card(
                  child: ListTile(
                    leading: Icon(
                      supabaseOk ? Icons.cloud_done : Icons.cloud_off,
                      color: supabaseOk ? Colors.green : Colors.grey,
                    ),
                    title: const Text('Supabase database'),
                    subtitle: Text(
                      supabaseOk
                          ? 'All data is loaded from and saved to Supabase'
                          : 'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sync
                Card(
                  child: Column(children: [
                    SwitchListTile(
                      title: const Text('Auto-sync'),
                      subtitle: const Text('Automatically refresh data on app start'),
                      value: _autoSync,
                      onChanged: (v) async {
                        await _saveBool(_kAutoSync, v);
                        setState(() => _autoSync = v);
                      },
                      secondary: const Icon(Icons.sync),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                _refreshAll();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync started')));
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Sync now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                // Privacy / Analytics
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable analytics'),
                    subtitle: const Text('Allow anonymous usage analytics to improve the app'),
                    value: _analytics,
                    onChanged: (v) async {
                      await _saveBool(_kAnalytics, v);
                      setState(() => _analytics = v);
                    },
                    secondary: const Icon(Icons.analytics),
                  ),
                ),
                const SizedBox(height: 12),
                // Onboarding
                Card(
                  child: SwitchListTile(
                    title: const Text('Onboarding seen'),
                    subtitle: const Text('Mark onboarding as completed'),
                    value: _onboardingSeen,
                    onChanged: (v) async {
                      await _saveBool(_kOnboarding, v);
                      setState(() => _onboardingSeen = v);
                    },
                    secondary: const Icon(Icons.info),
                  ),
                ),
                const SizedBox(height: 12),
                // Preferences
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: _language,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'sw', child: Text('Swahili')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await _saveString(_kLanguage, v);
                        setState(() => _language = v);
                                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language saved (app restart may be required)')));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Defaults with quick presets
                Card(
                  child: Column(children: [
                    ListTile(
                      title: const Text('Low-stock threshold'),
                      subtitle: Text('$_lowStock packets'),
                      trailing: PopupMenuButton<int>(
                        onSelected: (v) async {
                          await _saveInt(_kLowStock, v);
                          setState(() => _lowStock = v);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 5, child: Text('5')), 
                          const PopupMenuItem(value: 10, child: Text('10')),
                          const PopupMenuItem(value: 20, child: Text('20')),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                    ListTile(
                      title: const Text('Expiry alert window'),
                      subtitle: Text('$_expiryDays days'),
                      trailing: PopupMenuButton<int>(
                        onSelected: (v) async {
                          await _saveInt(_kExpiryDays, v);
                          setState(() => _expiryDays = v);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 7, child: Text('7 days')),
                          const PopupMenuItem(value: 14, child: Text('14 days')),
                          const PopupMenuItem(value: 30, child: Text('30 days')),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Reset
                FilledButton(
                  onPressed: () async {
                    await _resetDefaults();
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings reset to defaults')));
                  },
                  child: const Text('Reset to defaults'),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
