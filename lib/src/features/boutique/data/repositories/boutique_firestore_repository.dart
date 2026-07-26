import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/boutique_model.dart';

/// Firestore repository for boutiques.
class BoutiqueFirestoreRepository {
  BoutiqueFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<BoutiqueModel>> watchBoutiques() {
    return _firestore
        .collection(FirestorePaths.boutiques)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_fromFirestore).toList();
        })
        .handleError((_) => <BoutiqueModel>[]);
  }

  Future<List<BoutiqueModel>> getBoutiques() async {
    try {
      final snap = await _firestore.collection(FirestorePaths.boutiques).get();
      return snap.docs.map(_fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  BoutiqueModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BoutiqueModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? 'Boutique',
      subtitle: data['subtitle'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
