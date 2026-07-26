import 'package:flutter/foundation.dart';

/// Immutable domain model representing a Boutique.
@immutable
class BoutiqueModel {
  const BoutiqueModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.logoUrl,
    required this.isActive,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? logoUrl;
  final bool isActive;

  BoutiqueModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? logoUrl,
    bool? isActive,
  }) {
    return BoutiqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoutiqueModel &&
        other.id == id &&
        other.name == name &&
        other.subtitle == subtitle &&
        other.logoUrl == logoUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, subtitle, logoUrl, isActive);
  }

  @override
  String toString() {
    return 'BoutiqueModel(id: $id, name: $name, subtitle: $subtitle, logoUrl: $logoUrl, isActive: $isActive)';
  }
}
