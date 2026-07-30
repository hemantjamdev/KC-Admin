import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';

/// Firestore repository for managing designs and availability.
class DesignFirestoreRepository {
  DesignFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<DesignModel>> watchDesigns(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.designs)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return list;
        })
        .handleError((_) => <DesignModel>[]);
  }

  Future<({List<DesignModel> items, String? lastDocId, bool hasMore})>
  fetchPaginatedDesigns({
    int limit = 20,
    String? startAfterId,
    String? categoryId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.designs)
        .orderBy('createdAt', descending: true)
        .limit(limit + 1);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (startAfterId != null && startAfterId.isNotEmpty) {
      final lastDoc = await _firestore
          .collection(FirestorePaths.designs)
          .doc(startAfterId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    final hasMore = docs.length > limit;

    final resultDocs = hasMore ? docs.take(limit).toList() : docs;
    final items = resultDocs.map(_fromFirestore).toList();
    final lastDocId = resultDocs.isNotEmpty ? resultDocs.last.id : null;

    return (items: items, lastDocId: lastDocId, hasMore: hasMore);
  }

  Future<void> createDesign(DesignModel design) async {
    await _firestore
        .collection(FirestorePaths.designs)
        .doc(design.id)
        .set(_toFirestore(design, isCreate: true));
  }

  Future<void> updateDesign(DesignModel design) async {
    await _firestore
        .collection(FirestorePaths.designs)
        .doc(design.id)
        .update(_toFirestore(design, isCreate: false));
  }

  Future<void> deleteDesign(String designId) async {
    await _firestore.collection(FirestorePaths.designs).doc(designId).delete();
  }

  Future<void> toggleDesignStatus(String designId) async {
    final docRef = _firestore.collection(FirestorePaths.designs).doc(designId);
    final snap = await docRef.get();
    final current = (snap.data()?['isActive'] as bool?) ?? true;
    await docRef.update({
      'isActive': !current,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveDesignAvailability(DesignAvailabilityModel record) async {
    await _firestore
        .collection(FirestorePaths.designAvailability)
        .doc(record.id)
        .set({
          'id': record.id,
          'boutiqueId': record.boutiqueId,
          'branchId': record.branchId,
          'designId': record.designId,
          'status': record.status.name,
          'displayOrder': record.displayOrder,
          'availableFrom': record.availableFrom != null
              ? Timestamp.fromDate(record.availableFrom!)
              : null,
          'availableUntil': record.availableUntil != null
              ? Timestamp.fromDate(record.availableUntil!)
              : null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> upsertAvailability({
    required String boutiqueId,
    required String branchId,
    required String designId,
    required String status,
  }) async {
    final docId = '${branchId}_$designId';
    await _firestore
        .collection(FirestorePaths.designAvailability)
        .doc(docId)
        .set({
          'id': docId,
          'boutiqueId': boutiqueId,
          'branchId': branchId,
          'designId': designId,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  DesignModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return DesignModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      shortDescription: data['shortDescription'] as String?,
      description: data['description'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      searchKeywords: List<String>.from(data['searchKeywords'] as List? ?? []),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      colors: List<String>.from(data['colors'] as List? ?? []),
      sizes: List<String>.from(data['sizes'] as List? ?? []),
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _toFirestore(
    DesignModel design, {
    required bool isCreate,
  }) {
    return {
      'id': design.id,
      'boutiqueId': design.boutiqueId,
      'categoryId': design.categoryId,
      'name': design.name,
      'slug': design.slug,
      'shortDescription': design.shortDescription,
      'description': design.description,
      'thumbnailUrl': design.thumbnailUrl,
      'imageUrls': design.imageUrls,
      'tags': design.tags,
      'searchKeywords': design.searchKeywords,
      'sortOrder': design.sortOrder,
      'isActive': design.isActive,
      'price': design.price,
      'colors': design.colors,
      'sizes': design.sizes,
      'likeCount': design.likeCount,
      'favoriteCount': design.favoriteCount,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
