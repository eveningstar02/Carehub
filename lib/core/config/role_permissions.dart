import 'package:carehub_app/core/enums/app_enums.dart';

/// Role-based feature access permissions
class RolePermissions {
  // Feature access map: feature_name -> list of allowed roles
  static const Map<String, List<UserRole>> featureAccess = {
    'impact': [UserRole.admin, UserRole.donor, UserRole.contributor],
    'inventory': [UserRole.admin, UserRole.contributor],
    'donations': [UserRole.admin, UserRole.donor],
    'distribution': [UserRole.admin, UserRole.contributor],
    'schools': [UserRole.admin, UserRole.contributor],
    'volunteers': [UserRole.admin, UserRole.contributor],
    'finance': [UserRole.admin],
    'settings': [UserRole.admin, UserRole.donor, UserRole.contributor],
  };

  /// Check if a role has access to a feature
  static bool hasFeatureAccess(UserRole role, String featureName) {
    return featureAccess[featureName]?.contains(role) ?? false;
  }

  /// Get list of allowed features for a role
  static List<String> getAllowedFeatures(UserRole role) {
    return featureAccess.entries
        .where((e) => e.value.contains(role))
        .map((e) => e.key)
        .toList();
  }

  /// Get display name for role
  static String getRoleDisplayName(UserRole role) => role.displayName;

  /// Get description for role
  static String getRoleDescription(UserRole role) => role.description;
}
