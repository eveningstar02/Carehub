# Role-Based Access Control (RBAC) - Implementation Guide

## Overview
Your CareHub app now has role-based access control with three main user roles:

### **Roles**

#### 1. **Admin/Staff** 
- **Description:** Full access to all features
- **Access:** Impact, Stock, Donations, Distribution, Schools, Volunteers, Finance, Settings

#### 2. **Donor** 
- **Description:** Record donations and view impact
- **Access:** Impact, Donations, Settings

#### 3. **Volunteer/Contributor** 
- **Description:** Record distributions and manage inventory
- **Access:** Impact, Stock, Distribution, Schools, Volunteers, Settings

---

## Files Created/Modified

### New Files
1. **`lib/core/enums/app_enums.dart`** - Added `UserRole` enum with extension methods
2. **`lib/core/config/role_permissions.dart`** - Role-based permission matrix
3. **`lib/core/config/role_restricted_widget.dart`** - UI components for role restrictions

### Updated Files
1. **`lib/data/models/user_profile.dart`** - Added `role` field to UserProfile
2. **`lib/features/auth/login_screen.dart`** - Added role selection during signup
3. **`lib/features/home/home_screen.dart`** - Dynamic tab filtering based on role
4. **`lib/providers/app_providers.dart`** - Added user profile and role providers

---

## How It Works

### 1. **Sign-Up Flow**
When users create an account, they select their role:
```
Sign Up → Select Role (Donor/Contributor/Admin) → Create Account
```

The selected role is stored in Supabase user metadata.

### 2. **Home Screen Navigation**
The HomeScreen dynamically shows/hides tabs based on user role:
- Only accessible tabs appear in the bottom navigation
- Invalid tab selections are automatically corrected

### 3. **Permission Checking**
Use `RolePermissions.hasFeatureAccess(role, feature)` to check permissions programmatically.

---

## Usage Examples

### Restrict a Widget by Role
```dart
RoleRestrictedWidget(
  featureName: 'finance',
  child: YourFinanceWidget(),
)
```

### Check Permission in Code
```dart
if (RolePermissions.hasFeatureAccess(userRole, 'donations')) {
  // Show donation features
}
```

### Show User Role Info Dialog
```dart
showUserRoleInfo(context, ref);
```

---

## Database Schema Notes

To sync roles with database (optional), add to `user_profiles` table:
```sql
ALTER TABLE user_profiles ADD COLUMN role TEXT DEFAULT 'contributor';
```

---

## Customizing Permissions

Edit `lib/core/config/role_permissions.dart` to modify feature access:

```dart
static const Map<String, List<UserRole>> featureAccess = {
  'feature_name': [UserRole.admin, UserRole.donor],
  // Add more as needed
};
```

---

## Future Enhancements
- [ ] Admin panel to manage user roles
- [ ] Time-based access restrictions
- [ ] Feature-level granular permissions
- [ ] Activity logging by role
