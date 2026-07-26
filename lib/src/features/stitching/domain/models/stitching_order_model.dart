import 'package:flutter/foundation.dart';

enum StitchingOrderStatus {
  received,
  measurements,
  cutting,
  stitching,
  qualityCheck,
  ready,
  completed;

  String get adminLabel {
    return switch (this) {
      StitchingOrderStatus.received => 'Received',
      StitchingOrderStatus.measurements => 'Measurements',
      StitchingOrderStatus.cutting => 'Cutting',
      StitchingOrderStatus.stitching => 'Stitching',
      StitchingOrderStatus.qualityCheck => 'Quality Check',
      StitchingOrderStatus.ready => 'Ready',
      StitchingOrderStatus.completed => 'Completed',
    };
  }

  String get customerLabel {
    return switch (this) {
      StitchingOrderStatus.received => 'Order Received',
      StitchingOrderStatus.measurements => 'Measurements Recorded',
      StitchingOrderStatus.cutting => 'Fabric Cutting',
      StitchingOrderStatus.stitching => 'Stitching in Progress',
      StitchingOrderStatus.qualityCheck => 'Quality Check',
      StitchingOrderStatus.ready => 'Ready for Collection',
      StitchingOrderStatus.completed => 'Completed',
    };
  }

  double get progressFraction {
    return switch (this) {
      StitchingOrderStatus.received => 0.14,
      StitchingOrderStatus.measurements => 0.28,
      StitchingOrderStatus.cutting => 0.42,
      StitchingOrderStatus.stitching => 0.57,
      StitchingOrderStatus.qualityCheck => 0.71,
      StitchingOrderStatus.ready => 0.85,
      StitchingOrderStatus.completed => 1.0,
    };
  }
}

/// Immutable model representing body & garment measurements.
@immutable
class MeasurementSummaryModel {
  const MeasurementSummaryModel({
    this.chest,
    this.waist,
    this.hip,
    this.shoulder,
    this.sleeveLength,
    this.garmentLength,
    this.inseam,
    this.unit = 'in',
  });

  final double? chest;
  final double? waist;
  final double? hip;
  final double? shoulder;
  final double? sleeveLength;
  final double? garmentLength;
  final double? inseam;
  final String unit;

  bool get isEmpty =>
      chest == null &&
      waist == null &&
      hip == null &&
      shoulder == null &&
      sleeveLength == null &&
      garmentLength == null &&
      inseam == null;

  MeasurementSummaryModel copyWith({
    double? chest,
    double? waist,
    double? hip,
    double? shoulder,
    double? sleeveLength,
    double? garmentLength,
    double? inseam,
    String? unit,
    bool clearChest = false,
    bool clearWaist = false,
    bool clearHip = false,
    bool clearShoulder = false,
    bool clearSleeveLength = false,
    bool clearGarmentLength = false,
    bool clearInseam = false,
  }) {
    return MeasurementSummaryModel(
      chest: clearChest ? null : (chest ?? this.chest),
      waist: clearWaist ? null : (waist ?? this.waist),
      hip: clearHip ? null : (hip ?? this.hip),
      shoulder: clearShoulder ? null : (shoulder ?? this.shoulder),
      sleeveLength: clearSleeveLength
          ? null
          : (sleeveLength ?? this.sleeveLength),
      garmentLength: clearGarmentLength
          ? null
          : (garmentLength ?? this.garmentLength),
      inseam: clearInseam ? null : (inseam ?? this.inseam),
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeasurementSummaryModel &&
        other.chest == chest &&
        other.waist == waist &&
        other.hip == hip &&
        other.shoulder == shoulder &&
        other.sleeveLength == sleeveLength &&
        other.garmentLength == garmentLength &&
        other.inseam == inseam &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
    chest,
    waist,
    hip,
    shoulder,
    sleeveLength,
    garmentLength,
    inseam,
    unit,
  );

  @override
  String toString() =>
      'MeasurementSummaryModel(chest: $chest, waist: $waist, unit: $unit)';
}

/// Minimal design reference inside a stitching order.
@immutable
class DesignReferenceModel {
  const DesignReferenceModel({
    this.designId,
    required this.designName,
    this.thumbnailUrl,
    required this.quantity,
    this.notes,
  });

  final String? designId;
  final String designName;
  final String? thumbnailUrl;
  final int quantity;
  final String? notes;

  bool get isCustom => designId == null || designId!.isEmpty;

  DesignReferenceModel copyWith({
    String? designId,
    String? designName,
    String? thumbnailUrl,
    int? quantity,
    String? notes,
    bool clearDesignId = false,
    bool clearThumbnailUrl = false,
    bool clearNotes = false,
  }) {
    return DesignReferenceModel(
      designId: clearDesignId ? null : (designId ?? this.designId),
      designName: designName ?? this.designName,
      thumbnailUrl: clearThumbnailUrl
          ? null
          : (thumbnailUrl ?? this.thumbnailUrl),
      quantity: quantity ?? this.quantity,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DesignReferenceModel &&
        other.designId == designId &&
        other.designName == designName &&
        other.thumbnailUrl == thumbnailUrl &&
        other.quantity == quantity &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      Object.hash(designId, designName, thumbnailUrl, quantity, notes);

  @override
  String toString() =>
      'DesignReferenceModel(name: $designName, qty: $quantity, custom: $isCustom)';
}

/// Immutable timeline history record for status changes.
@immutable
class StitchingOrderHistoryModel {
  const StitchingOrderHistoryModel({
    required this.id,
    required this.stitchingOrderId,
    required this.boutiqueId,
    required this.branchId,
    required this.customerId,
    required this.status,
    this.note,
    required this.changedAt,
    this.changedBy,
  });

  final String id;
  final String stitchingOrderId;
  final String boutiqueId;
  final String branchId;
  final String customerId;
  final StitchingOrderStatus status;
  final String? note;
  final DateTime changedAt;
  final String? changedBy;

  StitchingOrderHistoryModel copyWith({
    String? id,
    String? stitchingOrderId,
    String? boutiqueId,
    String? branchId,
    String? customerId,
    StitchingOrderStatus? status,
    String? note,
    DateTime? changedAt,
    String? changedBy,
    bool clearNote = false,
    bool clearChangedBy = false,
  }) {
    return StitchingOrderHistoryModel(
      id: id ?? this.id,
      stitchingOrderId: stitchingOrderId ?? this.stitchingOrderId,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      note: clearNote ? null : (note ?? this.note),
      changedAt: changedAt ?? this.changedAt,
      changedBy: clearChangedBy ? null : (changedBy ?? this.changedBy),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StitchingOrderHistoryModel &&
        other.id == id &&
        other.stitchingOrderId == stitchingOrderId &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.customerId == customerId &&
        other.status == status &&
        other.note == note &&
        other.changedAt == changedAt &&
        other.changedBy == changedBy;
  }

  @override
  int get hashCode => Object.hash(
    id,
    stitchingOrderId,
    boutiqueId,
    branchId,
    customerId,
    status,
    note,
    changedAt,
    changedBy,
  );

  @override
  String toString() =>
      'StitchingOrderHistoryModel(id: $id, status: ${status.name}, at: $changedAt)';
}

/// Immutable main domain model for a stitching order.
@immutable
class StitchingOrderModel {
  const StitchingOrderModel({
    required this.id,
    required this.boutiqueId,
    required this.branchId,
    required this.customerId,
    required this.orderNumber,
    required this.status,
    required this.designReferences,
    this.measurementSummary,
    this.notes,
    this.expectedReadyAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String boutiqueId;
  final String branchId;
  final String customerId;
  final String orderNumber;
  final StitchingOrderStatus status;
  final List<DesignReferenceModel> designReferences;
  final MeasurementSummaryModel? measurementSummary;
  final String? notes;
  final DateTime? expectedReadyAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  StitchingOrderModel copyWith({
    String? id,
    String? boutiqueId,
    String? branchId,
    String? customerId,
    String? orderNumber,
    StitchingOrderStatus? status,
    List<DesignReferenceModel>? designReferences,
    MeasurementSummaryModel? measurementSummary,
    String? notes,
    DateTime? expectedReadyAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool clearMeasurementSummary = false,
    bool clearNotes = false,
    bool clearExpectedReadyAt = false,
    bool clearCompletedAt = false,
    bool clearCreatedBy = false,
    bool clearUpdatedBy = false,
  }) {
    return StitchingOrderModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      designReferences: designReferences ?? this.designReferences,
      measurementSummary: clearMeasurementSummary
          ? null
          : (measurementSummary ?? this.measurementSummary),
      notes: clearNotes ? null : (notes ?? this.notes),
      expectedReadyAt: clearExpectedReadyAt
          ? null
          : (expectedReadyAt ?? this.expectedReadyAt),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
      updatedBy: clearUpdatedBy ? null : (updatedBy ?? this.updatedBy),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StitchingOrderModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.customerId == customerId &&
        other.orderNumber == orderNumber &&
        other.status == status &&
        _listEquals(other.designReferences, designReferences) &&
        other.measurementSummary == measurementSummary &&
        other.notes == notes &&
        other.expectedReadyAt == expectedReadyAt &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.createdBy == createdBy &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode => Object.hash(
    id,
    boutiqueId,
    branchId,
    customerId,
    orderNumber,
    status,
    Object.hashAll(designReferences),
    measurementSummary,
    notes,
    expectedReadyAt,
    completedAt,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
  );

  @override
  String toString() =>
      'StitchingOrderModel(id: $id, number: $orderNumber, status: ${status.name})';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
