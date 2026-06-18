import 'package:carehub_app/data/models/json_helpers.dart';

class Volunteer {
  Volunteer({
    this.id,
    required this.name,
    this.contactDetails,
    this.role,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : updatedAt = updatedAt ?? DateTime.now(), deletedAt = deletedAt;

  String? id;
  String name;
  String? contactDetails;
  String? role;
  DateTime updatedAt;
  DateTime? deletedAt;

  factory Volunteer.fromJson(Map<String, dynamic> row) {
    return Volunteer(
      id: row['id'] as String?,
      name: row['name'] as String,
      contactDetails: row['contact_details'] as String?,
      role: row['role'] as String?,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
      deletedAt: parseJsonDate(row['deleted_at']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'name': name,
        'contact_details': contactDetails,
        'role': role,
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };
}

class VolunteerActivity {
  VolunteerActivity({
    this.id,
    this.volunteerId,
    required this.description,
    required this.activityDate,
    this.activityType,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : updatedAt = updatedAt ?? DateTime.now(), deletedAt = deletedAt;

  String? id;
  String? volunteerId;
  String description;
  DateTime activityDate;
  String? activityType;
  DateTime updatedAt;
  DateTime? deletedAt;

  factory VolunteerActivity.fromJson(Map<String, dynamic> row) {
    return VolunteerActivity(
      id: row['id'] as String?,
      volunteerId: row['volunteer_id'] as String?,
      description: row['description'] as String,
      activityDate: parseJsonDate(row['activity_date']) ?? DateTime.now(),
      activityType: row['activity_type'] as String?,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
      deletedAt: parseJsonDate(row['deleted_at']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'volunteer_id': volunteerId,
        'description': description,
        'activity_date': activityDate.toIso8601String(),
        'activity_type': activityType,
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };
}
