import 'package:carehub_app/core/config/app_config.dart';
import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/models/pad_inventory_item.dart';
import 'package:carehub_app/data/models/stock_settings.dart';
import 'package:carehub_app/data/supabase/supabase_table.dart';

class StockAlert {
  StockAlert({
    required this.item,
    required this.message,
    required this.severity,
  });

  final PadInventoryItem item;
  final String message;
  final AlertSeverity severity;
}

enum AlertSeverity { warning, critical }

class InventoryRepository with SupabaseTable {
  static const _table = 'pad_inventory';

  Future<List<PadInventoryItem>> getAll() async {
    final rows = await db.from(_table).select().order('updated_at');
    return mapRows(rows, PadInventoryItem.fromJson);
  }

  Future<PadInventoryItem?> getById(String id) async {
    final row = await db.from(_table).select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return PadInventoryItem.fromJson(Map<String, dynamic>.from(row));
  }

  CareHubQrPayload qrPayloadFor(PadInventoryItem item) {
    if (item.id == null) {
      throw StateError('Save item before generating QR');
    }
    return CareHubQrPayload.inventory(
      id: item.id!,
      brand: item.brand,
      type: item.type,
      absorbencyLevel: item.absorbencyLevel,
      padCategory: item.padCategory.name,
      color: item.color,
      packetSize: item.packetSize,
      batchNumber: item.batchNumber,
      storageLocation: item.storageLocation,
      expiryDate: item.expiryDate?.toIso8601String(),
    );
  }

  Future<PadInventoryItem> save(PadInventoryItem item) async {
    item.updatedAt = DateTime.now();
    final payload = item.toJson(includeId: false);

    if (item.id == null) {
      final row =
          await db.from(_table).insert(payload).select().single();
      return PadInventoryItem.fromJson(Map<String, dynamic>.from(row));
    }

    final row = await db
        .from(_table)
        .update(payload)
        .eq('id', item.id!)
        .select()
        .single();
    return PadInventoryItem.fromJson(Map<String, dynamic>.from(row));
  }

  Future<List<StockAlert>> getAlerts() async {
    final items = await getAll();
    final settings = await _loadStockSettings();
    final now = DateTime.now();
    final alerts = <StockAlert>[];

    for (final item in items) {
      final threshold = item.lowStockThreshold > 0
          ? item.lowStockThreshold
          : settings.defaultLowStockThreshold;

      if (item.quantityInStock <= 0) {
        alerts.add(StockAlert(
          item: item,
          message: '${item.brand} — out of stock',
          severity: AlertSeverity.critical,
        ));
      } else if (item.quantityInStock <= threshold) {
        alerts.add(StockAlert(
          item: item,
          message: '${item.brand} — low stock (${item.quantityInStock} left)',
          severity: AlertSeverity.warning,
        ));
      }

      if (item.expiryDate != null) {
        final days = item.expiryDate!.difference(now).inDays;
        if (days < 0) {
          alerts.add(StockAlert(
            item: item,
            message: '${item.brand} — expired',
            severity: AlertSeverity.critical,
          ));
        } else if (days <= settings.expiryAlertDays) {
          alerts.add(StockAlert(
            item: item,
            message: '${item.brand} — expires in $days days',
            severity: AlertSeverity.warning,
          ));
        }
      }
    }
    return alerts;
  }

  Future<StockSettings> _loadStockSettings() async {
    try {
      final row = await db
          .from('stock_settings')
          .select()
          .limit(1)
          .maybeSingle();
      if (row != null) {
        return StockSettings.fromJson(Map<String, dynamic>.from(row));
      }
    } catch (_) {}
    return StockSettings(
      defaultLowStockThreshold: AppConfig.defaultLowStockThreshold,
      expiryAlertDays: AppConfig.defaultExpiryAlertDays,
    );
  }
}
