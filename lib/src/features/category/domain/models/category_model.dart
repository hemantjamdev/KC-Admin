import 'package:flutter/foundation.dart';

/// Immutable domain model representing a Category belonging to a Boutique.
@immutable
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.boutiqueId,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isSystem = false,
  });

  final String id;
  final String boutiqueId;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;

  CategoryModel copyWith({
    String? id,
    String? boutiqueId,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    bool clearDescription = false,
    bool clearImageUrl = false,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: clearDescription ? null : (description ?? this.description),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.name == name &&
        other.slug == slug &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSystem == isSystem;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    name,
    slug,
    description,
    imageUrl,
    sortOrder,
    isActive,
    createdAt,
    updatedAt,
    isSystem,
  );

  @override
  String toString() {
    return 'CategoryModel(id: $id, boutiqueId: $boutiqueId, name: $name, '
        'slug: $slug, sortOrder: $sortOrder, isActive: $isActive, isSystem: $isSystem)';
  }
}
