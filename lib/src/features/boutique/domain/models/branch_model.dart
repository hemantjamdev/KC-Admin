import 'package:flutter/foundation.dart';

/// Immutable domain model representing a Branch.
@immutable
class BranchModel {
  const BranchModel({
    required this.id,
    required this.boutiqueId,
    required this.name,
    required this.address,
    required this.city,
    required this.isActive,
  });

  final String id;
  final String boutiqueId;
  final String name;
  final String address;
  final String city;
  final bool isActive;

  BranchModel copyWith({
    String? id,
    String? boutiqueId,
    String? name,
    String? address,
    String? city,
    bool? isActive,
  }) {
    return BranchModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BranchModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.name == name &&
        other.address == address &&
        other.city == city &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, boutiqueId, name, address, city, isActive);
  }

  @override
  String toString() {
    return 'BranchModel(id: $id, boutiqueId: $boutiqueId, name: $name, address: $address, city: $city, isActive: $isActive)';
  }
}
