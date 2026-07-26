import 'package:flutter/foundation.dart';

/// Availability status options for a design at a specific branch.
enum AvailabilityStatus {
  available,
  unavailable,
  hidden;

  String get label {
    return switch (this) {
      AvailabilityStatus.available => 'Available',
      AvailabilityStatus.unavailable => 'Unavailable',
      AvailabilityStatus.hidden => 'Hidden',
    };
  }
}

/// Immutable model for branch-specific design availability.
/// Firestore ID: `branchId_designId` (deterministic).
@immutable
class DesignAvailabilityModel {
  const DesignAvailabilityModel({
    required this.id,
    required this.boutiqueId,
    required this.branchId,
    required this.designId,
    required this.status,
    required this.displayOrder,
    this.availableFrom,
    this.availableUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deterministic ID: `branchId_designId`
  final String id;
  final String boutiqueId;
  final String branchId;
  final String designId;
  final AvailabilityStatus status;
  final int displayOrder;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether this availability record allows customer visibility right now.
  bool get isCurrentlyAvailable {
    if (status != AvailabilityStatus.available) return false;
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) return false;
    if (availableUntil != null && now.isAfter(availableUntil!)) return false;
    return true;
  }

  static String buildId(String branchId, String designId) =>
      '${branchId}_$designId';

  DesignAvailabilityModel copyWith({
    String? id,
    String? boutiqueId,
    String? branchId,
    String? designId,
    AvailabilityStatus? status,
    int? displayOrder,
    DateTime? availableFrom,
    DateTime? availableUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearAvailableFrom = false,
    bool clearAvailableUntil = false,
  }) {
    return DesignAvailabilityModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: branchId ?? this.branchId,
      designId: designId ?? this.designId,
      status: status ?? this.status,
      displayOrder: displayOrder ?? this.displayOrder,
      availableFrom: clearAvailableFrom
          ? null
          : (availableFrom ?? this.availableFrom),
      availableUntil: clearAvailableUntil
          ? null
          : (availableUntil ?? this.availableUntil),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DesignAvailabilityModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.designId == designId &&
        other.status == status &&
        other.displayOrder == displayOrder &&
        other.availableFrom == availableFrom &&
        other.availableUntil == availableUntil &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    branchId,
    designId,
    status,
    displayOrder,
    availableFrom,
    availableUntil,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'DesignAvailabilityModel(id: $id, designId: $designId, '
      'branchId: $branchId, status: ${status.name}, '
      'displayOrder: $displayOrder)';
}
