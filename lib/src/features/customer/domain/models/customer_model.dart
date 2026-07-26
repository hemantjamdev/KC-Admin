import 'package:flutter/foundation.dart';

/// Allowed source origin for customer profiles.
enum CustomerSource {
  google,
  admin;

  String get label {
    return switch (this) {
      CustomerSource.google => 'Google',
      CustomerSource.admin => 'Admin Created',
    };
  }
}

/// Immutable domain model representing a customer profile.
@immutable
class CustomerModel {
  const CustomerModel({
    required this.id,
    this.firebaseUid,
    required this.displayName,
    this.email,
    this.phone,
    this.photoUrl,
    required this.boutiqueIds,
    required this.branchIds,
    required this.source,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Permanent customer UUID
  final String id;

  /// Firebase Auth UID (null for admin-created customers until linked)
  final String? firebaseUid;

  final String displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final List<String> boutiqueIds;
  final List<String> branchIds;
  final CustomerSource source;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  bool get isFirebaseLinked => firebaseUid != null && firebaseUid!.isNotEmpty;

  CustomerModel copyWith({
    String? id,
    String? firebaseUid,
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    List<String>? boutiqueIds,
    List<String>? branchIds,
    CustomerSource? source,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool clearFirebaseUid = false,
    bool clearEmail = false,
    bool clearPhone = false,
    bool clearPhotoUrl = false,
    bool clearCreatedBy = false,
    bool clearUpdatedBy = false,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      firebaseUid: clearFirebaseUid ? null : (firebaseUid ?? this.firebaseUid),
      displayName: displayName ?? this.displayName,
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      boutiqueIds: boutiqueIds ?? this.boutiqueIds,
      branchIds: branchIds ?? this.branchIds,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
      updatedBy: clearUpdatedBy ? null : (updatedBy ?? this.updatedBy),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerModel &&
        other.id == id &&
        other.firebaseUid == firebaseUid &&
        other.displayName == displayName &&
        other.email == email &&
        other.phone == phone &&
        other.photoUrl == photoUrl &&
        _listEquals(other.boutiqueIds, boutiqueIds) &&
        _listEquals(other.branchIds, branchIds) &&
        other.source == source &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.createdBy == createdBy &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode => Object.hash(
    id,
    firebaseUid,
    displayName,
    email,
    phone,
    photoUrl,
    Object.hashAll(boutiqueIds),
    Object.hashAll(branchIds),
    source,
    isActive,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
  );

  @override
  String toString() =>
      'CustomerModel(id: $id, displayName: $displayName, email: $email, '
      'source: ${source.name}, firebaseUid: $firebaseUid, isActive: $isActive)';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
