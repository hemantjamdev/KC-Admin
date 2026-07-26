import 'package:flutter/foundation.dart';

enum AdminRole {
  superAdmin,
  boutiqueAdmin,
  branchAdmin;

  static AdminRole fromString(String role) {
    return switch (role.toLowerCase()) {
      'superadmin' => AdminRole.superAdmin,
      'boutiqueadmin' => AdminRole.boutiqueAdmin,
      'branchadmin' => AdminRole.branchAdmin,
      _ => AdminRole.branchAdmin,
    };
  }
}

@immutable
class AdminProfileModel {
  const AdminProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.boutiqueIds,
    required this.branchIds,
    required this.isActive,
  });

  final String id;
  final String email;
  final String displayName;
  final AdminRole role;
  final List<String> boutiqueIds;
  final List<String> branchIds;
  final bool isActive;
}

/// Service managing role-based authorization rules for admins.
class AdminAuthorizationService {
  const AdminAuthorizationService({required this.adminProfile});

  final AdminProfileModel adminProfile;

  bool get isActive => adminProfile.isActive;

  bool canAccessBoutique(String boutiqueId) {
    if (!isActive) return false;
    if (adminProfile.role == AdminRole.superAdmin) return true;
    return adminProfile.boutiqueIds.contains(boutiqueId);
  }

  bool canAccessBranch(String branchId) {
    if (!isActive) return false;
    if (adminProfile.role == AdminRole.superAdmin) return true;
    return adminProfile.branchIds.contains(branchId);
  }

  bool get canManageCategories => isActive;
  bool get canManageDesigns => isActive;
  bool get canManageSections => isActive;
  bool get canManageCustomers => isActive;
  bool get canManageStitchingOrders => isActive;
  bool get canManageNotifications => isActive;
}
