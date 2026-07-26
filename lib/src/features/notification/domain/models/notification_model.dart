import 'package:flutter/foundation.dart';

enum NotificationType {
  general,
  stitchingUpdate,
  designUpdate,
  boutiqueAnnouncement;

  String get label {
    return switch (this) {
      NotificationType.general => 'General',
      NotificationType.stitchingUpdate => 'Stitching Update',
      NotificationType.designUpdate => 'Design Update',
      NotificationType.boutiqueAnnouncement => 'Boutique Announcement',
    };
  }
}

enum NotificationAudienceType {
  allBoutiqueCustomers,
  branchCustomers,
  selectedCustomers;

  String get label {
    return switch (this) {
      NotificationAudienceType.allBoutiqueCustomers => 'All Boutique Customers',
      NotificationAudienceType.branchCustomers => 'Branch Customers',
      NotificationAudienceType.selectedCustomers => 'Selected Customers',
    };
  }
}

enum NotificationStatus {
  draft,
  scheduled,
  published,
  cancelled,
  archived;

  String get label {
    return switch (this) {
      NotificationStatus.draft => 'Draft',
      NotificationStatus.scheduled => 'Scheduled',
      NotificationStatus.published => 'Published',
      NotificationStatus.cancelled => 'Cancelled',
      NotificationStatus.archived => 'Archived',
    };
  }
}

enum NotificationDestinationType {
  none,
  design,
  section,
  stitchingOrder,
  customerProfile;

  String get label {
    return switch (this) {
      NotificationDestinationType.none => 'No Destination',
      NotificationDestinationType.design => 'Design Details',
      NotificationDestinationType.section => 'Curated Section',
      NotificationDestinationType.stitchingOrder => 'Stitching Order',
      NotificationDestinationType.customerProfile => 'My Profile',
    };
  }
}

/// Immutable main domain model for notifications.
@immutable
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.boutiqueId,
    this.branchId,
    required this.title,
    required this.body,
    required this.type,
    required this.audienceType,
    required this.customerIds,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.status,
    this.scheduledAt,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String boutiqueId;
  final String? branchId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationAudienceType audienceType;
  final List<String> customerIds;
  final NotificationDestinationType? relatedEntityType;
  final String? relatedEntityId;
  final NotificationStatus status;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  NotificationModel copyWith({
    String? id,
    String? boutiqueId,
    String? branchId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationAudienceType? audienceType,
    List<String>? customerIds,
    NotificationDestinationType? relatedEntityType,
    String? relatedEntityId,
    NotificationStatus? status,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool clearBranchId = false,
    bool clearRelatedEntityType = false,
    bool clearRelatedEntityId = false,
    bool clearScheduledAt = false,
    bool clearPublishedAt = false,
    bool clearExpiresAt = false,
    bool clearCreatedBy = false,
    bool clearUpdatedBy = false,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      audienceType: audienceType ?? this.audienceType,
      customerIds: customerIds ?? this.customerIds,
      relatedEntityType: clearRelatedEntityType
          ? null
          : (relatedEntityType ?? this.relatedEntityType),
      relatedEntityId: clearRelatedEntityId
          ? null
          : (relatedEntityId ?? this.relatedEntityId),
      status: status ?? this.status,
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      publishedAt: clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
      updatedBy: clearUpdatedBy ? null : (updatedBy ?? this.updatedBy),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.boutiqueId == boutiqueId &&
        other.branchId == branchId &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.audienceType == audienceType &&
        _listEquals(other.customerIds, customerIds) &&
        other.relatedEntityType == relatedEntityType &&
        other.relatedEntityId == relatedEntityId &&
        other.status == status &&
        other.scheduledAt == scheduledAt &&
        other.publishedAt == publishedAt &&
        other.expiresAt == expiresAt &&
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
    title,
    body,
    type,
    audienceType,
    Object.hashAll(customerIds),
    relatedEntityType,
    relatedEntityId,
    status,
    scheduledAt,
    publishedAt,
    expiresAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'NotificationModel(id: $id, title: $title, status: ${status.name})';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
