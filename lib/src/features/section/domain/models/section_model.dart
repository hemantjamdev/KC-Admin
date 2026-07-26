import 'package:flutter/foundation.dart';

/// Allowed section behavior types.
enum SectionType {
  manual,
  newArrivals,
  recommended;

  String get label {
    return switch (this) {
      SectionType.manual => 'Manual',
      SectionType.newArrivals => 'New Arrivals',
      SectionType.recommended => 'Recommended',
    };
  }
}

/// Immutable domain model representing a curated section on customer home screen.
@immutable
class SectionModel {
  const SectionModel({
    required this.id,
    required this.boutiqueId,
    this.branchId,
    required this.title,
    this.subtitle,
    required this.type,
    required this.sortOrder,
    required this.isActive,
    this.startAt,
    this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String boutiqueId;
  final String? branchId;
  final String title;
  final String? subtitle;
  final SectionType type;
  final int sortOrder;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  SectionModel copyWith({
    String? id,
    String? boutiqueId,
    String? branchId,
    String? title,
    String? subtitle,
    SectionType? type,
    int? sortOrder,
    bool? isActive,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBranchId = false,
    bool clearSubtitle = false,
    bool clearStartAt = false,
    bool clearEndAt = false,
  }) {
    return SectionModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SectionModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.type == type &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.startAt == startAt &&
        other.endAt == endAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    branchId,
    title,
    subtitle,
    type,
    sortOrder,
    isActive,
    startAt,
    endAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'SectionModel(id: $id, title: $title, type: ${type.name}, '
      'branchId: $branchId, sortOrder: $sortOrder, isActive: $isActive)';
}
