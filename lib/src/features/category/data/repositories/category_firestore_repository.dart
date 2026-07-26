import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/category_model.dart';

/// Firestore repository for managing categories.
class CategoryFirestoreRepository {
  CategoryFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<CategoryModel>> watchCategories(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.categories)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return list;
        })
        .handleError((_) => <CategoryModel>[]);
  }

  Future<void> createCategory(CategoryModel category) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(category.id)
        .set(_toFirestore(category, isCreate: true));
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(category.id)
        .update(_toFirestore(category, isCreate: false));
  }

  Future<void> setCategoryActiveStatus(String categoryId, bool isActive) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(categoryId)
        .update({
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  CategoryModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return CategoryModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _toFirestore(
    CategoryModel category, {
    required bool isCreate,
  }) {
    return {
      'id': category.id,
      'boutiqueId': category.boutiqueId,
      'name': category.name,
      'slug': category.slug,
      'description': category.description,
      'imageUrl': category.imageUrl,
      'sortOrder': category.sortOrder,
      'isActive': category.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
