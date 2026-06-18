import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class PadInventoryItem {
  PadInventoryItem({
    this.id,
    required this.brand,
    required this.type,
    required this.absorbencyLevel,
    required this.padCategory,
    this.color,
    this.packetSize = 1,
    this.quantityInStock = 0,
    this.batchNumber,
    this.expiryDate,
    this.storageLocation,
    this.costPerPacket,
    this.lowStockThreshold = 50,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  String brand;
  String type;
  String absorbencyLevel;
  PadCategory padCategory;
  String? color;
  int packetSize;
  int quantityInStock;
  String? batchNumber;
  DateTime? expiryDate;
  String? storageLocation;
  double? costPerPacket;
  int lowStockThreshold;
  DateTime updatedAt;

  factory PadInventoryItem.fromJson(Map<String, dynamic> row) {
    return PadInventoryItem(
      id: row['id'] as String?,
      brand: row['brand'] as String,
      type: row['type'] as String,
      absorbencyLevel: row['absorbency_level'] as String,
      padCategory: enumFromName(
        PadCategory.values,
        row['pad_category'] as String?,
        PadCategory.disposable,
      ),
      color: row['color'] as String?,
      packetSize: (row['packet_size'] as num?)?.toInt() ?? 1,
      quantityInStock: (row['quantity_in_stock'] as num?)?.toInt() ?? 0,
      batchNumber: row['batch_number'] as String?,
      expiryDate: parseJsonDate(row['expiry_date']),
      storageLocation: row['storage_location'] as String?,
      costPerPacket: (row['cost_per_packet'] as num?)?.toDouble(),
      lowStockThreshold: (row['low_stock_threshold'] as num?)?.toInt() ?? 50,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'brand': brand,
        'type': type,
        'absorbency_level': absorbencyLevel,
        'pad_category': padCategory.name,
        'color': color,
        'packet_size': packetSize,
        'quantity_in_stock': quantityInStock,
        'batch_number': batchNumber,
        'expiry_date': expiryDate?.toIso8601String(),
        'storage_location': storageLocation,
        'cost_per_packet': costPerPacket,
        'low_stock_threshold': lowStockThreshold,
        'updated_at': updatedAt.toIso8601String(),
      };
}
