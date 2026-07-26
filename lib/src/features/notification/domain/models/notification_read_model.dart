import 'package:flutter/foundation.dart';

/// Immutable model representing customer notification-read status.
@immutable
class NotificationReadModel {
  const NotificationReadModel({
    required this.id,
    required this.notificationId,
    required this.customerId,
    this.readAt,
    required this.createdAt,
  });

  /// Deterministic ID: `${notificationId}_${customerId}`
  final String id;
  final String notificationId;
  final String customerId;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  NotificationReadModel copyWith({
    String? id,
    String? notificationId,
    String? customerId,
    DateTime? readAt,
    DateTime? createdAt,
    bool clearReadAt = false,
  }) {
    return NotificationReadModel(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      customerId: customerId ?? this.customerId,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationReadModel &&
        other.id == id &&
        other.notificationId == notificationId &&
        other.customerId == customerId &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, notificationId, customerId, readAt, createdAt);

  @override
  String toString() =>
      'NotificationReadModel(id: $id, read: $isRead, readAt: $readAt)';
}
