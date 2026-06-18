class UserSettings {
  final String userId;
  final bool autoSync;
  final bool analyticsEnabled;
  final int lowStockThreshold;
  final int expiryAlertDays;
  final bool onboardingSeen;
  final DateTime? updatedAt;

  UserSettings({
    required this.userId,
    required this.autoSync,
    required this.analyticsEnabled,
    required this.lowStockThreshold,
    required this.expiryAlertDays,
    required this.onboardingSeen,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        userId: json['user_id'] as String,
        autoSync: json['auto_sync'] as bool? ?? false,
        analyticsEnabled: json['analytics_enabled'] as bool? ?? true,
        lowStockThreshold: json['low_stock_threshold'] as int? ?? 10,
        expiryAlertDays: json['expiry_alert_days'] as int? ?? 14,
        onboardingSeen: json['onboarding_seen'] as bool? ?? false,
        updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'auto_sync': autoSync,
        'analytics_enabled': analyticsEnabled,
        'low_stock_threshold': lowStockThreshold,
        'expiry_alert_days': expiryAlertDays,
        'onboarding_seen': onboardingSeen,
        'updated_at': updatedAt?.toIso8601String(),
      };
}
