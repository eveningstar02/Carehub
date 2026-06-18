import 'dart:convert';

/// QR payload types aligned with Supabase / Isar entities.
enum CareHubQrType {
  inventory,
  donation,
  distribution,
  school,
  community,
  beneficiary,
  volunteer,
}

/// Versioned JSON payload stored in QR codes.
class CareHubQrPayload {
  CareHubQrPayload({
    required this.type,
    this.id,
    this.fields = const {},
  });

  static const int currentVersion = 1;
  static const String prefix = 'carehub:';

  final CareHubQrType type;
  final String? id;
  final Map<String, dynamic> fields;

  String encode() => '$prefix${jsonEncode(toJson())}';

  Map<String, dynamic> toJson() => {
        'v': currentVersion,
        't': type.name,
        if (id != null) 'id': id,
        ...fields,
      };

  static CareHubQrPayload? decode(String raw) {
    var text = raw.trim();
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
    }

    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static CareHubQrPayload? fromJson(Map<String, dynamic> map) {
    final version = map['v'] as int? ?? 1;
    if (version != currentVersion) return null;

    final typeName = map['t'] as String?;
    if (typeName == null) return null;

    CareHubQrType? type;
    for (final e in CareHubQrType.values) {
      if (e.name == typeName) {
        type = e;
        break;
      }
    }
    if (type == null) return null;

    final id = map['id'] as String?;
    final reserved = {'v', 't', 'id'};
    final fields = <String, dynamic>{};
    map.forEach((key, value) {
      if (!reserved.contains(key)) fields[key] = value;
    });

    return CareHubQrPayload(type: type, id: id, fields: fields);
  }

  String? field(String key) => fields[key]?.toString();

  static CareHubQrPayload inventory({
    required String id,
    required String brand,
    required String type,
    required String absorbencyLevel,
    String? padCategory,
    String? color,
    int? packetSize,
    String? batchNumber,
    String? storageLocation,
    String? expiryDate,
  }) {
    return CareHubQrPayload(
      type: CareHubQrType.inventory,
      id: id,
      fields: {
        'brand': brand,
        'type': type,
        'absorbency_level': absorbencyLevel,
        'pad_category': ?padCategory,
        'color': ?color,
        'packet_size': ?packetSize,
        'batch_number': ?batchNumber,
        'storage_location': ?storageLocation,
        'expiry_date': ?expiryDate,
      },
    );
  }

  static CareHubQrPayload school({
    required String id,
    required String name,
    String? location,
    String? contactPerson,
  }) {
    return CareHubQrPayload(
      type: CareHubQrType.school,
      id: id,
      fields: {
        'name': name,
        'location': ?location,
        'contact_person': ?contactPerson,
      },
    );
  }

  static CareHubQrPayload volunteer({
    required String id,
    required String name,
    String? role,
  }) {
    return CareHubQrPayload(
      type: CareHubQrType.volunteer,
      id: id,
      fields: {
        'name': name,
        'role': ?role,
      },
    );
  }
}
