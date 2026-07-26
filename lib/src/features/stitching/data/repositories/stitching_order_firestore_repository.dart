import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/stitching_order_model.dart';

/// Firestore repository for stitching orders with batch transactions.
class StitchingOrderFirestoreRepository {
  StitchingOrderFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<StitchingOrderModel>> watchAdminOrders(
    String boutiqueId,
    String? branchId,
  ) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.stitchingOrders)
        .where('boutiqueId', isEqualTo: boutiqueId);

    if (branchId != null) {
      query = query.where('branchId', isEqualTo: branchId);
    }

    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((_) => <StitchingOrderModel>[]);
  }

  Stream<List<StitchingOrderModel>> watchCustomerOrders(
    String boutiqueId,
    String customerId,
  ) {
    return _firestore
        .collection(FirestorePaths.stitchingOrders)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((_) => <StitchingOrderModel>[]);
  }

  Future<void> createOrderWithHistory({
    required StitchingOrderModel order,
    required String initialNote,
    required String createdBy,
  }) async {
    final batch = _firestore.batch();

    final orderRef = _firestore
        .collection(FirestorePaths.stitchingOrders)
        .doc(order.id);
    batch.set(orderRef, _toFirestore(order, isCreate: true));

    final historyId = '${order.id}_initial';
    final historyRef = _firestore
        .collection(FirestorePaths.stitchingOrderHistory)
        .doc(historyId);

    batch.set(historyRef, {
      'id': historyId,
      'stitchingOrderId': order.id,
      'boutiqueId': order.boutiqueId,
      'branchId': order.branchId,
      'customerId': order.customerId,
      'status': order.status.name,
      'note': initialNote,
      'changedAt': FieldValue.serverTimestamp(),
      'changedBy': createdBy,
    });

    await batch.commit();
  }

  Future<void> updateOrderStatusWithHistory({
    required String orderId,
    required StitchingOrderStatus newStatus,
    required String? note,
    required String updatedBy,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final orderRef = _firestore
        .collection(FirestorePaths.stitchingOrders)
        .doc(orderId);

    final Map<String, dynamic> updateData = {
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    };

    if (newStatus == StitchingOrderStatus.completed) {
      updateData['completedAt'] = FieldValue.serverTimestamp();
    }

    batch.update(orderRef, updateData);

    final historyId = '${orderId}_${now.millisecondsSinceEpoch}';
    final historyRef = _firestore
        .collection(FirestorePaths.stitchingOrderHistory)
        .doc(historyId);

    batch.set(historyRef, {
      'id': historyId,
      'stitchingOrderId': orderId,
      'status': newStatus.name,
      'note': note,
      'changedAt': FieldValue.serverTimestamp(),
      'changedBy': updatedBy,
    });

    await batch.commit();
  }

  StitchingOrderModel _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final statusStr = data['status'] as String? ?? 'received';
    final status = StitchingOrderStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => StitchingOrderStatus.received,
    );

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return StitchingOrderModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      orderNumber: data['orderNumber'] as String? ?? 'ORD-000',
      status: status,
      designReferences: const [],
      notes: data['notes'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _toFirestore(
    StitchingOrderModel order, {
    required bool isCreate,
  }) {
    return {
      'id': order.id,
      'boutiqueId': order.boutiqueId,
      'branchId': order.branchId,
      'customerId': order.customerId,
      'orderNumber': order.orderNumber,
      'status': order.status.name,
      'notes': order.notes,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
