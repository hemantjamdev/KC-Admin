import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/section_model.dart';

/// Firestore repository for managing sections and section items.
class SectionFirestoreRepository {
  SectionFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<SectionModel>> watchSections(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.sections)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return list;
        })
        .handleError((_) => <SectionModel>[]);
  }

  Future<void> createSection(SectionModel section) async {
    await _firestore
        .collection(FirestorePaths.sections)
        .doc(section.id)
        .set(_toFirestore(section, isCreate: true));
  }

  Future<void> updateSection(SectionModel section) async {
    await _firestore
        .collection(FirestorePaths.sections)
        .doc(section.id)
        .update(_toFirestore(section, isCreate: false));
  }

  SectionModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final typeStr = data['type'] as String? ?? 'manual';
    final type = SectionType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => SectionType.manual,
    );

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return SectionModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String?,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String?,
      type: type,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _toFirestore(
    SectionModel section, {
    required bool isCreate,
  }) {
    return {
      'id': section.id,
      'boutiqueId': section.boutiqueId,
      'branchId': section.branchId,
      'title': section.title,
      'subtitle': section.subtitle,
      'type': section.type.name,
      'sortOrder': section.sortOrder,
      'isActive': section.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
