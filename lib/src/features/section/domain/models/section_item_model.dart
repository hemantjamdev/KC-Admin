import 'package:flutter/foundation.dart';

/// Immutable domain model representing a design item reference inside a manual section.
@immutable
class SectionItemModel {
  const SectionItemModel({
    required this.id,
    required this.boutiqueId,
    this.branchId,
    required this.sectionId,
    required this.designId,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String boutiqueId;
  final String? branchId;
  final String sectionId;
  final String designId;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SectionItemModel copyWith({
    String? id,
    String? boutiqueId,
    String? branchId,
    String? sectionId,
    String? designId,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBranchId = false,
  }) {
    return SectionItemModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      sectionId: sectionId ?? this.sectionId,
      designId: designId ?? this.designId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SectionItemModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.sectionId == sectionId &&
        other.designId == designId &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    branchId,
    sectionId,
    designId,
    sortOrder,
    isActive,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'SectionItemModel(id: $id, sectionId: $sectionId, designId: $designId, '
      'sortOrder: $sortOrder)';
}
