import 'package:carehub_app/core/config/app_config.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class StockSettings {
  StockSettings({
    this.id,
    this.defaultLowStockThreshold = AppConfig.defaultLowStockThreshold,
    this.expiryAlertDays = AppConfig.defaultExpiryAlertDays,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  int defaultLowStockThreshold;
  int expiryAlertDays;
  DateTime updatedAt;

  factory StockSettings.fromJson(Map<String, dynamic> row) {
    return StockSettings(
      id: row['id'] as String?,
      defaultLowStockThreshold:
          (row['default_low_stock_threshold'] as num?)?.toInt() ??
              AppConfig.defaultLowStockThreshold,
      expiryAlertDays: (row['expiry_alert_days'] as num?)?.toInt() ??
          AppConfig.defaultExpiryAlertDays,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }
}
