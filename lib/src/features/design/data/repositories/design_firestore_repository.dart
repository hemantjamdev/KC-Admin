import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/design_model.dart';

/// Firestore repository for managing designs and availability.
class DesignFirestoreRepository {
  DesignFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<DesignModel>> watchDesigns(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.designs)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return list;
        })
        .handleError((_) => <DesignModel>[]);
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
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
