enum PadCategory { disposable, reusable }

enum DonationType { pads, monetary, mixed, other }

enum FinancialType { monetaryDonation, purchase, expense }

enum RecipientType { school, beneficiary, community }

enum AgeGroup { under10, age10to14, age15to19, over19, unknown }

enum UserRole { admin, donor, contributor }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin/Staff';
      case UserRole.donor:
        return 'Donor';
      case UserRole.contributor:
        return 'Volunteer/Contributor';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Full access to all features';
      case UserRole.donor:
        return 'Record donations and view impact';
      case UserRole.contributor:
        return 'Record distributions and manage inventory';
    }
  }
}
