import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/notification_model.dart';

/// Firestore repository for Admin notifications and publication tracking.
class NotificationFirestoreRepository {
  NotificationFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> watchAdminNotifications() {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Stream.value(<NotificationModel>[]);
      }
    } catch (_) {}

    return _firestore.collection(FirestorePaths.notifications).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map(_fromFirestore).where(_isAdminVisible).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static bool _isAdminVisible(NotificationModel n) {
    // Exclude private customer-only order status updates
    final isCustomerOrderUpdate =
        n.audienceType == NotificationAudienceType.selectedCustomers &&
        (n.type == NotificationType.stitchingUpdate ||
            n.type == NotificationType.stitchingStatusUpdated);
    if (isCustomerOrderUpdate) {
      return false;
    }

    // Show Admin-targeted alerts (e.g. new stitching requests)
    final isAdminAlert = n.audienceType == NotificationAudienceType.admins ||
        n.type == NotificationType.newStitchingRequest;

    // Show store broadcast announcements created for customers
    final isBroadcastAnnouncement =
        n.audienceType == NotificationAudienceType.allBoutiqueCustomers ||
        n.audienceType == NotificationAudienceType.branchCustomers ||
        n.status == NotificationStatus.draft;

    return isAdminAlert || isBroadcastAnnouncement;
  }

  Future<({List<NotificationModel> items, String? lastDocId, bool hasMore})>
  fetchPaginatedNotifications({int limit = 20, String? startAfterId}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.notifications)
        .orderBy('createdAt', descending: true)
        .limit(limit * 2);

    if (startAfterId != null && startAfterId.isNotEmpty) {
      final lastDoc = await _firestore
          .collection(FirestorePaths.notifications)
          .doc(startAfterId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    final allParsed = snapshot.docs.map(_fromFirestore).where(_isAdminVisible).toList();
    final hasMore = allParsed.length > limit;
    final items = hasMore ? allParsed.take(limit).toList() : allParsed;
    final lastDocId = snapshot.docs.isNotEmpty ? snapshot.docs.last.id : null;

    return (items: items, lastDocId: lastDocId, hasMore: hasMore);
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .set(_toFirestore(notification, isCreate: true));
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notificationId)
        .delete();
  }

  Future<void> publishNotification(String notificationId) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notificationId)
        .update({
          'status': 'published',
          'publishedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .update(_toFirestore(notification, isCreate: false));
  }

  Future<void> markAsRead(String notificationId, String adminUid) async {
    final docId = '${notificationId}_$adminUid';
    await _firestore
        .collection(FirestorePaths.notificationReads)
        .doc(docId)
        .set({
          'id': docId,
          'notificationId': notificationId,
          'uid': adminUid,
          'customerId': adminUid,
          'readAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<Set<String>> watchReadNotificationIds(String uid) {
    if (uid.isEmpty) return Stream.value(<String>{});
    return _firestore
        .collection(FirestorePaths.notificationReads)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['notificationId'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();
        });
  }

  NotificationModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final typeStr = data['type'] as String? ?? 'general';
    final type = NotificationType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => NotificationType.general,
    );

    final statusStr = data['status'] as String? ?? 'draft';
    final status = NotificationStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => NotificationStatus.draft,
    );

    final audienceStr =
        data['audienceType'] as String? ?? data['audience'] as String? ?? 'allBoutiqueCustomers';
    final audience = (audienceStr == 'admins' || audienceStr == 'admin')
        ? NotificationAudienceType.admins
        : NotificationAudienceType.values.firstWhere(
            (a) => a.name == audienceStr,
            orElse: () => NotificationAudienceType.allBoutiqueCustomers,
          );

    final relTypeStr = data['relatedEntityType'] as String?;
    NotificationDestinationType? relatedEntityType;
    if (relTypeStr != null && relTypeStr.isNotEmpty) {
      relatedEntityType = NotificationDestinationType.values.firstWhere(
        (e) => e.name == relTypeStr,
        orElse: () => NotificationDestinationType.none,
      );
    }

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    final publishedAtRaw = data['publishedAt'];
    final publishedAt = publishedAtRaw is Timestamp
        ? publishedAtRaw.toDate()
        : null;

    final scheduledAtRaw = data['scheduledAt'];
    final scheduledAt = scheduledAtRaw is Timestamp
        ? scheduledAtRaw.toDate()
        : null;

    final expiresAtRaw = data['expiresAt'];
    final expiresAt = expiresAtRaw is Timestamp ? expiresAtRaw.toDate() : null;

    final rawCustomerIds =
        data['customerIds'] as List? ?? data['targetCustomerUids'] as List? ?? [];

    return NotificationModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String?,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: type,
      audienceType: audience,
      customerIds: List<String>.from(rawCustomerIds),
      relatedEntityType: relatedEntityType,
      relatedEntityId: data['relatedEntityId'] as String?,
      status: status,
      scheduledAt: scheduledAt,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(
    NotificationModel notification, {
    required bool isCreate,
  }) {
    return {
      'id': notification.id,
      'boutiqueId': notification.boutiqueId,
      'branchId': notification.branchId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.name,
      'audienceType': notification.audienceType.name,
      'customerIds': notification.customerIds,
      'relatedEntityType': notification.relatedEntityType?.name,
      'relatedEntityId': notification.relatedEntityId,
      'status': notification.status.name,
      'scheduledAt': notification.scheduledAt != null
          ? Timestamp.fromDate(notification.scheduledAt!)
          : null,
      'publishedAt': notification.publishedAt != null
          ? Timestamp.fromDate(notification.publishedAt!)
          : (notification.status == NotificationStatus.published
                ? FieldValue.serverTimestamp()
                : null),
      'expiresAt': notification.expiresAt != null
          ? Timestamp.fromDate(notification.expiresAt!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'createdBy': notification.createdBy,
      'updatedBy': notification.updatedBy,
    };
  }
}
