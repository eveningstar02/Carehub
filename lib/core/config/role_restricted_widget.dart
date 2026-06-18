import 'package:carehub_app/core/config/role_permissions.dart';
import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper widget to restrict access to features based on user role
class RoleRestrictedWidget extends ConsumerWidget {
  final String featureName;
  final Widget child;
  final Widget? restrictedWidget;

  const RoleRestrictedWidget({
    super.key,
    required this.featureName,
    required this.child,
    this.restrictedWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      data: (role) {
        final hasAccess = RolePermissions.hasFeatureAccess(role, featureName);

        if (hasAccess) {
          return child;
        }

        return restrictedWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Access Restricted',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your role (${role.displayName}) does not have access to this feature.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

/// Dialog to show user role and permissions
void showUserRoleInfo(BuildContext context, WidgetRef ref) {
  final userRoleAsync = ref.watch(userRoleProvider);

  showDialog(
    context: context,
    builder: (ctx) => userRoleAsync.when(
      data: (role) {
        final allowedFeatures = RolePermissions.getAllowedFeatures(role);

        return AlertDialog(
          title: const Text('Your Role & Permissions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Role: ${role.displayName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(role.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Text(
                  'Access to:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...allowedFeatures.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(feature),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
      loading: () => const AlertDialog(
        title: Text('Loading...'),
        content: CircularProgressIndicator(),
      ),
      error: (e, st) =>
          AlertDialog(title: const Text('Error'), content: Text('$e')),
    ),
  );
}
