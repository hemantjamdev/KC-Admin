import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/branch_model.dart';

/// Firestore repository for branches.
class BranchFirestoreRepository {
  BranchFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<BranchModel>> watchBranchesForBoutique(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.branches)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_fromFirestore).toList();
        })
        .handleError((_) => <BranchModel>[]);
  }

  Future<List<BranchModel>> getBranchesForBoutique(String boutiqueId) async {
    try {
      final snap = await _firestore
          .collection(FirestorePaths.branches)
          .where('boutiqueId', isEqualTo: boutiqueId)
          .get();
      return snap.docs.map(_fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  BranchModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BranchModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      name: data['name'] as String? ?? 'Branch',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
