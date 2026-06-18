import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class DistributionRecord {
  DistributionRecord({
    this.id,
    required this.distributionDate,
    required this.recipientType,
    this.recipientName,
    this.schoolId,
    this.beneficiaryId,
    this.communityId,
    this.quantity = 0,
    this.brand,
    this.volunteerId,
    this.location,
    this.notes,
    this.inventoryItemId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : updatedAt = updatedAt ?? DateTime.now(), deletedAt = deletedAt;

  String? id;
  DateTime distributionDate;
  RecipientType recipientType;
  String? recipientName;
  String? schoolId;
  String? beneficiaryId;
  String? communityId;
  int quantity;
  String? brand;
  String? volunteerId;
  String? location;
  String? notes;
  String? inventoryItemId;
  DateTime updatedAt;
  DateTime? deletedAt;

  factory DistributionRecord.fromJson(Map<String, dynamic> row) {
    return DistributionRecord(
      id: row['id'] as String?,
      distributionDate:
          parseJsonDate(row['distribution_date']) ?? DateTime.now(),
      recipientType: enumFromName(
        RecipientType.values,
        row['recipient_type'] as String?,
        RecipientType.school,
      ),
      recipientName: row['recipient_name'] as String?,
      schoolId: row['school_id'] as String?,
      beneficiaryId: row['beneficiary_id'] as String?,
      communityId: row['community_id'] as String?,
      quantity: (row['quantity'] as num?)?.toInt() ?? 0,
      brand: row['brand'] as String?,
      volunteerId: row['volunteer_id'] as String?,
      location: row['location'] as String?,
      notes: row['notes'] as String?,
      inventoryItemId: row['inventory_item_id'] as String?,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
      deletedAt: parseJsonDate(row['deleted_at']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'distribution_date': distributionDate.toIso8601String(),
        'recipient_type': recipientType.name,
        'recipient_name': recipientName,
        'school_id': schoolId,
        'beneficiary_id': beneficiaryId,
        'community_id': communityId,
        'quantity': quantity,
        'brand': brand,
        'volunteer_id': volunteerId,
        'location': location,
        'notes': notes,
        'inventory_item_id': inventoryItemId,
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };
}
