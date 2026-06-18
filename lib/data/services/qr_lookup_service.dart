import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/repositories/community_repository.dart';
import 'package:carehub_app/data/repositories/inventory_repository.dart';
import 'package:carehub_app/data/repositories/school_repository.dart';
import 'package:carehub_app/data/repositories/volunteer_repository.dart';

/// Resolves QR payloads from Supabase.
class QrLookupService {
  QrLookupService({
    InventoryRepository? inventory,
    SchoolRepository? schools,
    VolunteerRepository? volunteers,
    CommunityRepository? communities,
  })  : _inventory = inventory ?? InventoryRepository(),
        _schools = schools ?? SchoolRepository(),
        _volunteers = volunteers ?? VolunteerRepository(),
        _communities = communities ?? CommunityRepository();

  final InventoryRepository _inventory;
  final SchoolRepository _schools;
  final VolunteerRepository _volunteers;
  final CommunityRepository _communities;

  Future<CareHubQrPayload?> resolvePayload(CareHubQrPayload scanned) async {
    if (scanned.id == null) return scanned;

    switch (scanned.type) {
      case CareHubQrType.inventory:
        final item = await _inventory.getById(scanned.id!);
        if (item == null) return scanned;
        return _inventory.qrPayloadFor(item);
      case CareHubQrType.school:
        final school = await _schools.getById(scanned.id!);
        if (school == null || school.id == null) return scanned;
        return CareHubQrPayload.school(
          id: school.id!,
          name: school.name,
          location: school.location,
          contactPerson: school.contactPerson,
        );
      case CareHubQrType.volunteer:
        final v = await _volunteers.getById(scanned.id!);
        if (v == null || v.id == null) return scanned;
        return CareHubQrPayload.volunteer(
          id: v.id!,
          name: v.name,
          role: v.role,
        );
      case CareHubQrType.community:
        final c = await _communities.getById(scanned.id!);
        if (c == null) return scanned;
        return CareHubQrPayload(
          type: CareHubQrType.community,
          id: c.id,
          fields: {
            'name': c.name,
            'location': ?c.location,
          },
        );
      case CareHubQrType.beneficiary:
      case CareHubQrType.donation:
      case CareHubQrType.distribution:
        return scanned;
    }
  }
}

class DistributionScanFill {
  DistributionScanFill({
    this.recipientType,
    this.recipientName,
    this.schoolId,
    this.beneficiaryId,
    this.communityId,
    this.brand,
    this.inventoryItemId,
    this.volunteerId,
    this.volunteerName,
    this.location,
    this.quantity,
  });

  final RecipientType? recipientType;
  final String? recipientName;
  final String? schoolId;
  final String? beneficiaryId;
  final String? communityId;
  final String? brand;
  final String? inventoryItemId;
  final String? volunteerId;
  final String? volunteerName;
  final String? location;
  final int? quantity;

  static DistributionScanFill? fromPayload(CareHubQrPayload p) {
    switch (p.type) {
      case CareHubQrType.inventory:
        return DistributionScanFill(
          brand: p.field('brand'),
          inventoryItemId: p.id,
        );
      case CareHubQrType.school:
        return DistributionScanFill(
          recipientType: RecipientType.school,
          recipientName: p.field('name'),
          schoolId: p.id,
          location: p.field('location'),
        );
      case CareHubQrType.community:
        return DistributionScanFill(
          recipientType: RecipientType.community,
          recipientName: p.field('name'),
          communityId: p.id,
          location: p.field('location'),
        );
      case CareHubQrType.beneficiary:
        return DistributionScanFill(
          recipientType: RecipientType.beneficiary,
          recipientName: p.field('unique_id'),
          beneficiaryId: p.id,
        );
      case CareHubQrType.volunteer:
        return DistributionScanFill(
          volunteerId: p.id,
          volunteerName: p.field('name'),
        );
      default:
        return null;
    }
  }
}

class DonationScanFill {
  DonationScanFill({
    this.inventoryItemId,
    this.donorName,
    this.quantity,
    this.notes,
  });

  final String? inventoryItemId;
  final String? donorName;
  final int? quantity;
  final String? notes;

  static DonationScanFill? fromPayload(CareHubQrPayload p) {
    if (p.type == CareHubQrType.inventory) {
      return DonationScanFill(
        inventoryItemId: p.id,
        notes: 'Batch ${p.field('batch_number') ?? ''}'.trim(),
      );
    }
    if (p.type == CareHubQrType.donation) {
      return DonationScanFill(
        donorName: p.field('donor_name'),
        quantity: int.tryParse(p.field('quantity') ?? ''),
        notes: p.field('notes'),
      );
    }
    return null;
  }
}

class InventoryScanFill {
  InventoryScanFill({
    this.id,
    this.brand,
    this.type,
    this.absorbencyLevel,
    this.padCategory,
    this.color,
    this.packetSize,
    this.batchNumber,
    this.storageLocation,
    this.expiryDate,
    this.quantityInStock,
    this.costPerPacket,
  });

  final String? id;
  final String? brand;
  final String? type;
  final String? absorbencyLevel;
  final PadCategory? padCategory;
  final String? color;
  final int? packetSize;
  final String? batchNumber;
  final String? storageLocation;
  final DateTime? expiryDate;
  final int? quantityInStock;
  final double? costPerPacket;

  static InventoryScanFill fromPayload(CareHubQrPayload p) {
    PadCategory? cat;
    final catName = p.field('pad_category');
    if (catName != null) {
      for (final e in PadCategory.values) {
        if (e.name == catName) {
          cat = e;
          break;
        }
      }
    }
    return InventoryScanFill(
      id: p.id,
      brand: p.field('brand'),
      type: p.field('type'),
      absorbencyLevel: p.field('absorbency_level'),
      padCategory: cat,
      color: p.field('color'),
      packetSize: int.tryParse(p.field('packet_size') ?? ''),
      batchNumber: p.field('batch_number'),
      storageLocation: p.field('storage_location'),
      expiryDate: DateTime.tryParse(p.field('expiry_date') ?? ''),
      quantityInStock: int.tryParse(p.field('quantity_in_stock') ?? ''),
      costPerPacket: double.tryParse(p.field('cost_per_packet') ?? ''),
    );
  }
}
