import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/repositories/shop_profile_repository.dart';
import '../../domain/models/shop_profile_model.dart';

/// Provides the singleton [ShopProfileRepository].
final shopProfileRepositoryProvider = Provider<ShopProfileRepository>((ref) {
  return ShopProfileRepository(firestore: ref.watch(firebaseFirestoreProvider));
});

/// Provides the live stream of the single Kapada Creation [ShopProfileModel].
final shopProfileStreamProvider = StreamProvider<ShopProfileModel>((ref) {
  ref.watch(firebaseAuthStateProvider);
  return ref.watch(shopProfileRepositoryProvider).watchShopProfile();
});

/// Provides the active [ShopProfileModel], falling back to default profile.
final shopProfileProvider = Provider<ShopProfileModel>((ref) {
  return ref.watch(shopProfileStreamProvider).valueOrNull ??
      ShopProfileModel.defaultProfile;
});
