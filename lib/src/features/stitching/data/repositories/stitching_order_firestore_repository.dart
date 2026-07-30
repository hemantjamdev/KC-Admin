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

  static final List<StitchingOrderModel> sampleOrders = [
    StitchingOrderModel(
      id: 'ord_sample_01',
      boutiqueId: 'boutique_01',
      branchId: 'branch_01',
      customerId: 'cust_101',
      customerName: 'Ananya Sharma',
      customerPhone: '+91 98765 43210',
      customerEmail: 'ananya.sharma@example.com',
      orderNumber: 'ORD-1001',
      status: StitchingOrderStatus.requested,
      requestName: 'Royal Velvet Anarkali Suit',
      categoryName: 'Festive',
      expectedReadyAt: DateTime.now().add(const Duration(days: 4)),
      designReferences: const [
        DesignReferenceModel(
          designId: 'des_01',
          designName: 'Royal Velvet Anarkali Suit',
          quantity: 1,
          notes: 'Golden zari border around sleeves & neckline',
        ),
      ],
      measurementSummary: const MeasurementSummaryModel(
        chest: 36.0,
        waist: 30.0,
        hip: 39.0,
        shoulder: 14.5,
        sleeveLength: 22.0,
        garmentLength: 52.0,
      ),
      notes: 'Urgent stitching request for upcoming wedding event',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    StitchingOrderModel(
      id: 'ord_sample_02',
      boutiqueId: 'boutique_01',
      branchId: 'branch_01',
      customerId: 'cust_102',
      customerName: 'Priya Verma',
      customerPhone: '+91 98123 45678',
      customerEmail: 'priya.verma@example.com',
      orderNumber: 'ORD-1002',
      status: StitchingOrderStatus.accepted,
      requestName: 'Embroidered Silk Lehenga Choli',
      categoryName: 'Seasonal',
      expectedReadyAt: DateTime.now().add(const Duration(days: 7)),
      designReferences: const [
        DesignReferenceModel(
          designId: 'des_02',
          designName: 'Embroidered Silk Lehenga Choli',
          quantity: 1,
          notes: 'Custom latkan tassels on dupatta',
        ),
      ],
      measurementSummary: const MeasurementSummaryModel(
        chest: 34.0,
        waist: 28.0,
        hip: 37.0,
        shoulder: 14.0,
        sleeveLength: 20.0,
        garmentLength: 42.0,
      ),
      notes: 'Fitting confirmed during in-store visit',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    StitchingOrderModel(
      id: 'ord_sample_03',
      boutiqueId: 'boutique_01',
      branchId: 'branch_01',
      customerId: 'cust_103',
      customerName: 'Kavita Singhania',
      customerPhone: '+91 99887 76655',
      customerEmail: 'kavita.s@example.com',
      orderNumber: 'ORD-1003',
      status: StitchingOrderStatus.completed,
      requestName: 'Handloom Cotton Designer Kurti',
      categoryName: 'New Arrival',
      expectedReadyAt: DateTime.now().add(const Duration(days: 12)),
      designReferences: const [
        DesignReferenceModel(
          designId: 'des_03',
          designName: 'Handloom Cotton Designer Kurti',
          quantity: 2,
        ),
      ],
      measurementSummary: const MeasurementSummaryModel(
        chest: 38.0,
        waist: 32.0,
        hip: 41.0,
        shoulder: 15.0,
        sleeveLength: 18.0,
        garmentLength: 44.0,
      ),
      notes: 'Completed & packed for pickup',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Stream<List<StitchingOrderModel>> watchAdminOrders([
    String? boutiqueId,
    String? branchId,
  ]) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Stream.value(sampleOrders);
      }
    } catch (_) {}

    Query<Map<String, dynamic>> query = _firestore.collection(
      FirestorePaths.stitchingOrders,
    );

    return query
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return sampleOrders;
          }
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort(_compareByPickupPriority);
          return list.isEmpty ? sampleOrders : list;
        })
        .handleError((error, stack) {
          debugPrint('[StitchingRepo] watchAdminOrders stream error: $error\n$stack');
          return sampleOrders;
        });
  }

  static int _compareByPickupPriority(StitchingOrderModel a, StitchingOrderModel b) {
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
        'accepted' => ['accepted', 'cutting', 'stitching', 'qualitycheck', 'qualityCheck'],
        'completed' => ['completed', 'ready'],
        _ => [status],
      };
      query = col.where('status', whereIn: rawStatuses);
    } else {
      query = col;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      Query<Map<String, dynamic>> orderedQuery = query.orderBy('createdAt', descending: true).limit(limit + 1);
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
      var filtered = sampleOrders;
      if (status != null && status.isNotEmpty && status != 'all') {
        final targetStatus = StitchingOrderStatus.parse(status);
        filtered = sampleOrders.where((o) => o.status == targetStatus).toList();
      }
      return (items: filtered, lastDocId: null, hasMore: false);
    }

    final lastDocId = resultDocs.isNotEmpty ? resultDocs.last.id : null;

    return (items: items, lastDocId: lastDocId, hasMore: hasMore);
  }

  /// Fast aggregate count query using Firestore count() aggregation (supports 10k+ docs with minimal reads).
  Future<({int total, int requested, int accepted, int completed})> fetchStatusCounts() async {
    try {
      final col = _firestore.collection(FirestorePaths.stitchingOrders);
      final totalSnap = await col.count().get();

      final requestedSnap = await col
          .where('status', whereIn: ['requested', 'received', 'measurements'])
          .count()
          .get();

      final acceptedSnap = await col
          .where('status', whereIn: ['accepted', 'cutting', 'stitching', 'qualitycheck', 'qualityCheck'])
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
        return (
          total: sampleOrders.length,
          requested: sampleOrders.where((o) => o.status == StitchingOrderStatus.requested).length,
          accepted: sampleOrders.where((o) => o.status == StitchingOrderStatus.accepted).length,
          completed: sampleOrders.where((o) => o.status == StitchingOrderStatus.completed).length,
        );
      }

      return (
        total: totalCount,
        requested: reqCount,
        accepted: accCount,
        completed: compCount,
      );
    } catch (_) {
      return (
        total: sampleOrders.length,
        requested: sampleOrders.where((o) => o.status == StitchingOrderStatus.requested).length,
        accepted: sampleOrders.where((o) => o.status == StitchingOrderStatus.accepted).length,
        completed: sampleOrders.where((o) => o.status == StitchingOrderStatus.completed).length,
      );
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

    // Automatically store notification in Firestore for both Admin & Customer apps
    final notificationId = 'notif_${order.id}';
    final notificationRef = _firestore
        .collection(FirestorePaths.notifications)
        .doc(notificationId);

    batch.set(notificationRef, {
      'id': notificationId,
      'boutiqueId': order.boutiqueId,
      'branchId': order.branchId,
      'title': 'New Stitching Request #${order.orderNumber}',
      'body': 'A new stitching request #${order.orderNumber} was placed.',
      'type': 'stitchingUpdate',
      'audienceType': 'selectedCustomers',
      'customerIds': [order.customerId],
      'relatedEntityType': 'stitchingOrder',
      'relatedEntityId': order.id,
      'status': 'published',
      'publishedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
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

    // Automatically store notification event in notifications collection
    final notifId = 'notif_${orderId}_${now.millisecondsSinceEpoch}';
    final notifRef = _firestore
        .collection(FirestorePaths.notifications)
        .doc(notifId);

    final statusLabel = newStatus.name.replaceAll('_', ' ').toUpperCase();
    batch.set(notifRef, {
      'id': notifId,
      'boutiqueId': 'boutique_kc_main',
      'title': 'Stitching Order Status: $statusLabel',
      'body':
          'Order details updated to $statusLabel.${note != null && note.isNotEmpty ? " Note: $note" : ""}',
      'type': 'stitchingUpdate',
      'audienceType': 'allBoutiqueCustomers',
      'customerIds': <String>[],
      'relatedEntityType': 'stitchingOrder',
      'relatedEntityId': orderId,
      'status': 'published',
      'publishedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': updatedBy,
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
      categoryName: data['categoryName'] as String? ?? data['category'] as String?,
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
