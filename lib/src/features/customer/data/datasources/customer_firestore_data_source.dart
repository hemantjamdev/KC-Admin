import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/customer_model.dart';

/// Low-level Firestore data source for managing the `customers` collection.
class CustomerFirestoreDataSource {
  CustomerFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('customers');

  /// Convert Firestore document map to [CustomerModel]
  CustomerModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Customer document ${doc.id} does not exist.');
    }

    final createdAtRaw = data['createdAt'];
    final updatedAtRaw = data['updatedAt'];

    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    final sourceStr = data['source'] as String? ?? 'admin';
    final source = sourceStr == 'google'
        ? CustomerSource.google
        : CustomerSource.admin;

    return CustomerModel(
      id: data['id'] as String? ?? doc.id,
      firebaseUid: data['firebaseUid'] as String?,
      displayName: data['displayName'] as String? ?? 'Customer',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      boutiqueIds: List<String>.from(data['boutiqueIds'] as List? ?? []),
      branchIds: List<String>.from(data['branchIds'] as List? ?? []),
      source: source,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  /// Convert [CustomerModel] to Firestore Map
  Map<String, dynamic> _toFirestore(
    CustomerModel model, {
    bool isCreate = false,
  }) {
    return {
      'id': model.id,
      'firebaseUid': model.firebaseUid,
      'displayName': model.displayName.trim(),
      'email': model.email?.trim().isEmpty == true ? null : model.email?.trim(),
      'phone': model.phone?.trim().isEmpty == true ? null : model.phone?.trim(),
      'photoUrl': model.photoUrl,
      'boutiqueIds': model.boutiqueIds,
      'branchIds': model.branchIds,
      'source': model.source.name,
      'isActive': model.isActive,
      'schemaVersion': 1,
      'createdBy': model.createdBy,
      'updatedBy': model.updatedBy,
      'createdAt': isCreate
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(model.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<CustomerModel?> fetchById(String customerId) async {
    try {
      final doc = await _collection.doc(customerId).get();
      if (!doc.exists) return null;
      return _fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch customer $customerId: $e');
    }
  }

  Future<CustomerModel?> fetchByFirebaseUid(String firebaseUid) async {
    try {
      final query = await _collection
          .where('firebaseUid', isEqualTo: firebaseUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return _fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch customer by Firebase UID: $e');
    }
  }

  Future<List<CustomerModel>> fetchAll({
    String? boutiqueId,
    bool? isActive,
    CustomerSource? source,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (source != null) {
        query = query.where('source', isEqualTo: source.name);
      }

      final snapshot = await query.get();
      final list = snapshot.docs.map(_fromFirestore).toList();

      // Deduplicate by email: when the same person has both an admin-created
      // record (no firebaseUid) and an app-linked record (with firebaseUid),
      // keep the more complete one (firebaseUid set wins).
      final seen = <String, CustomerModel>{};
      for (final customer in list) {
        final key = customer.email?.trim().toLowerCase() ?? customer.id;
        final existing = seen[key];
        if (existing == null) {
          seen[key] = customer;
        } else {
          // Prefer the record that has a firebaseUid (more complete).
          if (customer.firebaseUid != null && existing.firebaseUid == null) {
            seen[key] = customer;
          }
        }
      }

      final deduplicated = seen.values.toList();
      deduplicated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return deduplicated;
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<({List<CustomerModel> items, String? lastDocId, bool hasMore})> fetchPaginated({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .orderBy('createdAt', descending: true)
          .limit(limit + 1);

      if (startAfterId != null && startAfterId.isNotEmpty) {
        final lastDoc = await _collection.doc(startAfterId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final hasMore = docs.length > limit;
      final resultDocs = hasMore ? docs.take(limit).toList() : docs;
      final rawItems = resultDocs.map(_fromFirestore).toList();

      // Deduplicate by email: when duplicate records exist with the same email address,
      // keep the primary record (preferring firebaseUid linked account).
      final seen = <String, CustomerModel>{};
      for (final customer in rawItems) {
        final key = customer.email?.trim().toLowerCase();
        if (key == null || key.isEmpty) {
          seen[customer.id] = customer;
        } else {
          final existing = seen[key];
          if (existing == null) {
            seen[key] = customer;
          } else {
            if (customer.firebaseUid != null && existing.firebaseUid == null) {
              seen[key] = customer;
            }
          }
        }
      }

      final items = seen.values.toList();
      final lastDocId = resultDocs.isNotEmpty ? resultDocs.last.id : null;

      return (items: items, lastDocId: lastDocId, hasMore: hasMore);
    } catch (e) {
      return (items: <CustomerModel>[], lastDocId: null, hasMore: false);
    }
  }

  Future<void> create(CustomerModel customer) async {
    try {
      final map = _toFirestore(customer, isCreate: true);
      await _collection.doc(customer.id).set(map);
    } catch (e) {
      throw Exception('Failed to create customer record: $e');
    }
  }

  Future<void> update(CustomerModel customer) async {
    try {
      final map = _toFirestore(customer, isCreate: false);
      await _collection.doc(customer.id).update(map);
    } catch (e) {
      throw Exception('Failed to update customer record: $e');
    }
  }

  Future<void> setActiveStatus(
    String customerId,
    bool isActive,
    String updatedBy,
  ) async {
    try {
      await _collection.doc(customerId).update({
        'isActive': isActive,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set customer active status: $e');
    }
  }
}
