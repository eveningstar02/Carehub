import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class DonationRecord {
  DonationRecord({
    this.id,
    required this.donorName,
    this.contactDetails,
    required this.donationDate,
    this.quantity = 0,
    required this.donationType,
    this.notes,
    this.inventoryItemId,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  String donorName;
  String? contactDetails;
  DateTime donationDate;
  int quantity;
  DonationType donationType;
  String? notes;
  String? inventoryItemId;
  DateTime updatedAt;

  factory DonationRecord.fromJson(Map<String, dynamic> row) {
    return DonationRecord(
      id: row['id'] as String?,
      donorName: row['donor_name'] as String,
      contactDetails: row['contact_details'] as String?,
      donationDate: parseJsonDate(row['donation_date']) ?? DateTime.now(),
      quantity: (row['quantity'] as num?)?.toInt() ?? 0,
      donationType: enumFromName(
        DonationType.values,
        row['donation_type'] as String?,
        DonationType.pads,
      ),
      notes: row['notes'] as String?,
      inventoryItemId: row['inventory_item_id'] as String?,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'donor_name': donorName,
        'contact_details': contactDetails,
        'donation_date': donationDate.toIso8601String(),
        'quantity': quantity,
        'donation_type': donationType.name,
        'notes': notes,
        'inventory_item_id': inventoryItemId,
        'updated_at': updatedAt.toIso8601String(),
      };
}
