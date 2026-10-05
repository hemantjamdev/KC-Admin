import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/stitching_order_model.dart';

/// Firestore repository for stitching orders with batch transactions.
class StitchingOrderFirestoreRepository {
  StitchingOrderFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<StitchingOrderModel> sampleOrders = [];

  Stream<List<StitchingOrderModel>> watchAdminOrders([
    String? boutiqueId,
    String? branchId,
  ]) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Stream.value(<StitchingOrderModel>[]);
      }
    } catch (_) {}

    Query<Map<String, dynamic>> query = _firestore.collection(
      FirestorePaths.stitchingOrders,
    );

    return query
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <StitchingOrderModel>[];
          }
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort(_compareByPickupPriority);
          return list;
        })
        .handleError((error, stack) {
          debugPrint(
            '[StitchingRepo] watchAdminOrders stream error: $error\n$stack',
          );
          return <StitchingOrderModel>[];
        });
  }

  static int _compareByPickupPriority(
    StitchingOrderModel a,
    StitchingOrderModel b,
  ) {
    final dateA = a.expectedReadyAt;
    final dateB = b.expectedReadyAt;

    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }
    if (dateA != null) return -1;
    if (dateB != null) return 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  Future<({List<StitchingOrderModel> items, String? lastDocId, bool hasMore})>
  fetchPaginatedOrders({
    int limit = 20,
    String? startAfterId,
    String? status,
  }) async {
    final col = _firestore.collection(FirestorePaths.stitchingOrders);

    Query<Map<String, dynamic>> query;
    if (status != null && status.isNotEmpty && status != 'all') {
      final List<String> rawStatuses = switch (status.toLowerCase()) {
        'requested' => ['requested', 'received', 'measurements'],
        'accepted' => [
          'accepted',
          'cutting',
          'stitching',
          'qualitycheck',
          'qualityCheck',
        ],
        'completed' => ['completed', 'ready'],
        _ => [status],
      };
      query = col.where('status', whereIn: rawStatuses);
    } else {
      query = col;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      Query<Map<String, dynamic>> orderedQuery = query
          .orderBy('createdAt', descending: true)
          .limit(limit + 1);
      if (startAfterId != null && startAfterId.isNotEmpty) {
        final lastDoc = await col.doc(startAfterId).get();
        if (lastDoc.exists) {
          orderedQuery = orderedQuery.startAfterDocument(lastDoc);
        }
      }
      snapshot = await orderedQuery.get();
    } catch (_) {
      Query<Map<String, dynamic>> fallbackQuery = query.limit(limit + 1);
      if (startAfterId != null && startAfterId.isNotEmpty) {
        final lastDoc = await col.doc(startAfterId).get();
        if (lastDoc.exists) {
          fallbackQuery = fallbackQuery.startAfterDocument(lastDoc);
        }
      }
      snapshot = await fallbackQuery.get();
    }

    final docs = snapshot.docs;
    final hasMore = docs.length > limit;

    final resultDocs = hasMore ? docs.take(limit).toList() : docs;
    final items = resultDocs.map(_fromFirestore).toList();
    items.sort(_compareByPickupPriority);

    if (items.isEmpty) {
      return (items: <StitchingOrderModel>[], lastDocId: null, hasMore: false);
    }

    final lastDocId = resultDocs.isNotEmpty ? resultDocs.last.id : null;

    return (items: items, lastDocId: lastDocId, hasMore: hasMore);
  }

  /// Fast aggregate count query using Firestore count() aggregation (supports 10k+ docs with minimal reads).
  Future<({int total, int requested, int accepted, int completed})>
  fetchStatusCounts() async {
    try {
      final col = _firestore.collection(FirestorePaths.stitchingOrders);
      final totalSnap = await col.count().get();

      final requestedSnap = await col
          .where('status', whereIn: ['requested', 'received', 'measurements'])
          .count()
          .get();

      final acceptedSnap = await col
          .where(
            'status',
            whereIn: [
              'accepted',
              'cutting',
              'stitching',
              'qualitycheck',
              'qualityCheck',
            ],
          )
          .count()
          .get();

      final completedSnap = await col
          .where('status', whereIn: ['completed', 'ready'])
          .count()
          .get();

      final reqCount = requestedSnap.count ?? 0;
      final accCount = acceptedSnap.count ?? 0;
      final compCount = completedSnap.count ?? 0;
      final totalCount = totalSnap.count ?? 0;

      if (totalCount == 0) {
        return (total: 0, requested: 0, accepted: 0, completed: 0);
      }

      return (
        total: totalCount,
        requested: reqCount,
        accepted: accCount,
        completed: compCount,
      );
    } catch (_) {
      return (total: 0, requested: 0, accepted: 0, completed: 0);
    }
  }

  Stream<List<StitchingOrderModel>> watchCustomerOrders(
    String boutiqueId,
    String customerId,
  ) {
    return _firestore
        .collection(FirestorePaths.stitchingOrders)
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
    });

    await batch.commit();
  }

  Future<void> updateOrder(StitchingOrderModel order) async {
    await _firestore
        .collection(FirestorePaths.stitchingOrders)
        .doc(order.id)
        .update(_toFirestore(order, isCreate: false));
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

  /// Fetch history timeline records for a specific stitching order from Firestore.
  Future<List<StitchingOrderHistoryModel>> fetchOrderHistory(
    String orderId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.stitchingOrderHistory)
          .where('stitchingOrderId', isEqualTo: orderId)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final statusStr = data['status'] as String?;
        final status = StitchingOrderStatus.parse(statusStr);
        final changedAtRaw = data['changedAt'];
        final changedAt = changedAtRaw is Timestamp
            ? changedAtRaw.toDate()
            : DateTime.now();

        return StitchingOrderHistoryModel(
          id: doc.id,
          stitchingOrderId: data['stitchingOrderId'] as String? ?? orderId,
          boutiqueId: data['boutiqueId'] as String? ?? '',
          branchId: data['branchId'] as String? ?? '',
          customerId: data['customerId'] as String? ?? '',
          status: status,
          note: data['note'] as String?,
          changedAt: changedAt,
          changedBy: data['changedBy'] as String? ?? 'Admin',
        );
      }).toList();

      list.sort((a, b) => a.changedAt.compareTo(b.changedAt));
      return list;
    } catch (_) {
      return <StitchingOrderHistoryModel>[];
    }
  }

  StitchingOrderModel _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final statusStr = data['status'] as String?;
    final status = StitchingOrderStatus.parse(statusStr);

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : (createdAtRaw is String
              ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
              : DateTime.now());

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : (updatedAtRaw is String
              ? (DateTime.tryParse(updatedAtRaw) ?? DateTime.now())
              : DateTime.now());

    final List<DesignReferenceModel> designRefs = [];
    if (data['designReferences'] is List) {
      final rawList = data['designReferences'] as List;
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          designRefs.add(
            DesignReferenceModel(
              designId: item['designId'] as String?,
              designName: item['designName'] as String? ?? 'Custom Design',
              thumbnailUrl: item['thumbnailUrl'] as String?,
              quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              notes: item['notes'] as String?,
            ),
          );
        }
      }
    } else if (data['designName'] != null) {
      designRefs.add(
        DesignReferenceModel(
          designName: data['designName'] as String,
          quantity: (data['quantity'] as num?)?.toInt() ?? 1,
          thumbnailUrl: data['thumbnailUrl'] as String?,
        ),
      );
    }

    final summaryRaw = data['measurementSummary'];
    MeasurementSummaryModel? measurementSummary;
    if (summaryRaw is Map<String, dynamic>) {
      measurementSummary = MeasurementSummaryModel(
        chest: (summaryRaw['chest'] as num?)?.toDouble(),
        waist: (summaryRaw['waist'] as num?)?.toDouble(),
        hip: (summaryRaw['hip'] as num?)?.toDouble(),
        shoulder: (summaryRaw['shoulder'] as num?)?.toDouble(),
        sleeveLength: (summaryRaw['sleeveLength'] as num?)?.toDouble(),
        garmentLength: (summaryRaw['garmentLength'] as num?)?.toDouble(),
        inseam: (summaryRaw['inseam'] as num?)?.toDouble(),
        unit: summaryRaw['unit'] as String? ?? 'in',
      );
    }

    final expectedReadyAtRaw = data['expectedReadyAt'] ?? data['pickupDate'];
    final expectedReadyAt = expectedReadyAtRaw is Timestamp
        ? expectedReadyAtRaw.toDate()
        : (expectedReadyAtRaw is String
              ? DateTime.tryParse(expectedReadyAtRaw)
              : null);

    return StitchingOrderModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName:
          data['customerName'] as String? ??
          data['customerDisplayName'] as String?,
      customerPhone: data['customerPhone'] as String?,
      customerEmail: data['customerEmail'] as String?,
      orderNumber: data['orderNumber'] as String? ?? 'ORD-000',
      status: status,
      requestName: data['requestName'] as String? ?? data['name'] as String?,
      categoryName:
          data['categoryName'] as String? ?? data['category'] as String?,
      designReferences: designRefs,
      measurementSummary: measurementSummary,
      notes: data['notes'] as String?,
      expectedReadyAt: expectedReadyAt,
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
      if (order.customerName != null) 'customerName': order.customerName,
      if (order.customerPhone != null) 'customerPhone': order.customerPhone,
      if (order.customerEmail != null) 'customerEmail': order.customerEmail,
      'orderNumber': order.orderNumber,
      'status': order.status.name,
      'requestName': order.requestName ?? order.displayRequestName,
      'categoryName': order.categoryName ?? order.displayCategoryName,
      'name': order.requestName ?? order.displayRequestName,
      'category': order.categoryName ?? order.displayCategoryName,
      if (order.expectedReadyAt != null)
        'pickupDate': Timestamp.fromDate(order.expectedReadyAt!),
      if (order.expectedReadyAt != null)
        'expectedReadyAt': Timestamp.fromDate(order.expectedReadyAt!),
      'notes': order.notes,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
