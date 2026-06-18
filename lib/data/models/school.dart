import 'package:carehub_app/data/models/json_helpers.dart';

class School {
  School({
    this.id,
    required this.name,
    this.location,
    this.contactPerson,
    this.contactPhone,
    this.girlsServed = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  String name;
  String? location;
  String? contactPerson;
  String? contactPhone;
  int girlsServed;
  DateTime updatedAt;

  factory School.fromJson(Map<String, dynamic> row) {
    return School(
      id: row['id'] as String?,
      name: row['name'] as String,
      location: row['location'] as String?,
      contactPerson: row['contact_person'] as String?,
      contactPhone: row['contact_phone'] as String?,
      girlsServed: (row['girls_served'] as num?)?.toInt() ?? 0,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'name': name,
        'location': location,
        'contact_person': contactPerson,
        'contact_phone': contactPhone,
        'girls_served': girlsServed,
        'updated_at': updatedAt.toIso8601String(),
      };
}
