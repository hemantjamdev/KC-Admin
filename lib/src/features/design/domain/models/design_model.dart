import 'package:flutter/foundation.dart';

/// Immutable domain model representing a Design in the boutique catalogue.
@immutable
class DesignModel {
  const DesignModel({
    required this.id,
    required this.boutiqueId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    this.thumbnailUrl,
    required this.imageUrls,
    required this.tags,
    required this.searchKeywords,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String boutiqueId;
  final String categoryId;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final List<String> tags;
  final List<String> searchKeywords;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DesignModel copyWith({
    String? id,
    String? boutiqueId,
    String? categoryId,
    String? name,
    String? slug,
    String? shortDescription,
    String? description,
    String? thumbnailUrl,
    List<String>? imageUrls,
    List<String>? tags,
    List<String>? searchKeywords,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearShortDescription = false,
    bool clearDescription = false,
    bool clearThumbnailUrl = false,
  }) {
    return DesignModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      shortDescription: clearShortDescription
          ? null
          : (shortDescription ?? this.shortDescription),
      description: clearDescription ? null : (description ?? this.description),
      thumbnailUrl: clearThumbnailUrl
          ? null
          : (thumbnailUrl ?? this.thumbnailUrl),
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DesignModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.slug == slug &&
        other.shortDescription == shortDescription &&
        other.description == description &&
        other.thumbnailUrl == thumbnailUrl &&
        _listEquals(other.imageUrls, imageUrls) &&
        _listEquals(other.tags, tags) &&
        _listEquals(other.searchKeywords, searchKeywords) &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    categoryId,
    name,
    slug,
    shortDescription,
    description,
    thumbnailUrl,
    Object.hashAll(imageUrls),
    Object.hashAll(tags),
    Object.hashAll(searchKeywords),
    sortOrder,
    isActive,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'DesignModel(id: $id, boutiqueId: $boutiqueId, categoryId: $categoryId, '
      'name: $name, slug: $slug, sortOrder: $sortOrder, isActive: $isActive)';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
