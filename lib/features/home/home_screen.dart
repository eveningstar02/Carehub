import 'package:carehub_app/features/donations/donations_screen.dart';
import 'package:carehub_app/features/distribution/distribution_screen.dart';
import 'package:carehub_app/features/finances/finances_screen.dart';
import 'package:carehub_app/features/inventory/inventory_screen.dart';
import 'package:carehub_app/features/impact/impact_screen.dart';
import 'package:carehub_app/features/schools/schools_screen.dart';
import 'package:carehub_app/features/settings/settings_screen.dart';
import 'package:carehub_app/features/volunteers/volunteers_screen.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:carehub_app/core/config/role_permissions.dart';
import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const _allTabs = [
    (icon: Icons.dashboard_outlined, label: 'Impact', feature: 'impact'),
    (icon: Icons.inventory_2_outlined, label: 'Stock', feature: 'inventory'),
    (
      icon: Icons.volunteer_activism_outlined,
      label: 'Donations',
      feature: 'donations',
    ),
    (
      icon: Icons.local_shipping_outlined,
      label: 'Distribute',
      feature: 'distribution',
    ),
    (icon: Icons.school_outlined, label: 'Schools', feature: 'schools'),
    (icon: Icons.groups_outlined, label: 'Volunteers', feature: 'volunteers'),
    (
      icon: Icons.account_balance_wallet_outlined,
      label: 'Finance',
      feature: 'finance',
    ),
    (icon: Icons.settings_outlined, label: 'Settings', feature: 'settings'),
  ];

  late final Map<String, Widget> _pageMap = const {
    'impact': ImpactScreen(),
    'inventory': InventoryScreen(),
    'donations': DonationsScreen(),
    'distribution': DistributionScreen(),
    'schools': SchoolsScreen(),
    'volunteers': VolunteersScreen(),
    'finance': FinancesScreen(),
    'settings': SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      data: (role) {
        // Filter tabs based on user role
        final allowedTabs = _allTabs
            .where((tab) => RolePermissions.hasFeatureAccess(role, tab.feature))
            .toList();

        if (_index >= allowedTabs.length) {
          _index = 0;
        }

        final currentTab = allowedTabs[_index];
        final currentPage = _pageMap[currentTab.feature];

        return Scaffold(
          body: currentPage,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final t in allowedTabs)
                NavigationDestination(icon: Icon(t.icon), label: t.label),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('Error loading user role: $e'))),
    );
  }
}
