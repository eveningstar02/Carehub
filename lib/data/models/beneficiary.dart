import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class Beneficiary {
  Beneficiary({
    this.id,
    required this.uniqueId,
    required this.ageGroup,
    this.schoolId,
    this.communityId,
    this.contactDetails,
    this.contactConsentGiven = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  String uniqueId;
  AgeGroup ageGroup;
  String? schoolId;
  String? communityId;
  String? contactDetails;
  bool contactConsentGiven;
  DateTime updatedAt;

  factory Beneficiary.fromJson(Map<String, dynamic> row) {
    return Beneficiary(
      id: row['id'] as String?,
      uniqueId: row['unique_id'] as String,
      ageGroup: enumFromName(
        AgeGroup.values,
        row['age_group'] as String?,
        AgeGroup.unknown,
      ),
      schoolId: row['school_id'] as String?,
      communityId: row['community_id'] as String?,
      contactDetails: row['contact_details'] as String?,
      contactConsentGiven: row['contact_consent_given'] as bool? ?? false,
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'unique_id': uniqueId,
        'age_group': ageGroup.name,
        'school_id': schoolId,
        'community_id': communityId,
        if (contactConsentGiven) 'contact_details': contactDetails,
        'contact_consent_given': contactConsentGiven,
        'updated_at': updatedAt.toIso8601String(),
      };
}
