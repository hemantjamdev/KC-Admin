import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/notification_model.dart';

/// Firestore repository for notifications and read state.
class NotificationFirestoreRepository {
  NotificationFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> watchNotifications(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.notifications)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((_) => <NotificationModel>[]);
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .set(_toFirestore(notification, isCreate: true));
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .update(_toFirestore(notification, isCreate: false));
  }

  Future<void> markAsRead(String notificationId, String customerId) async {
    final docId = '${notificationId}_$customerId';
    await _firestore
        .collection(FirestorePaths.notificationReads)
        .doc(docId)
        .set({
          'id': docId,
          'notificationId': notificationId,
          'customerId': customerId,
          'readAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
        data['audienceType'] as String? ?? 'allBoutiqueCustomers';
    final audience = NotificationAudienceType.values.firstWhere(
      (a) => a.name == audienceStr,
      orElse: () => NotificationAudienceType.allBoutiqueCustomers,
    );

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return NotificationModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String?,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: type,
      audienceType: audience,
      customerIds: List<String>.from(data['customerIds'] as List? ?? []),
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
      'status': notification.status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
