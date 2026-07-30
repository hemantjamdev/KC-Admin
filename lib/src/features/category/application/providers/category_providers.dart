import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/category/data/repositories/category_firestore_repository.dart';
import 'package:kc_admin/src/features/category/domain/models/category_model.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final categoryRepositoryProvider = Provider<CategoryFirestoreRepository>((ref) {
  return CategoryFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// ─────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────

enum CategoryStatusFilter { all, active, inactive }

class CategoryFilterState {
  const CategoryFilterState({
    this.searchQuery = '',
    this.statusFilter = CategoryStatusFilter.all,
  });
  final String searchQuery;
  final CategoryStatusFilter statusFilter;

  CategoryFilterState copyWith({
    String? searchQuery,
    CategoryStatusFilter? statusFilter,
  }) => CategoryFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: statusFilter ?? this.statusFilter,
  );
}

// ─────────────────────────────────────────────
// Category list — live stream for selected boutique
// ─────────────────────────────────────────────

/// Provides a live stream of all categories for the currently selected boutique.
final categoryListProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories('boutique_01');
});

// ─────────────────────────────────────────────
// Filter provider (admin)
// ─────────────────────────────────────────────

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, CategoryFilterState>(
      CategoryFilterNotifier.new,
    );

class CategoryFilterNotifier extends Notifier<CategoryFilterState> {
  @override
  CategoryFilterState build() => const CategoryFilterState();

  void search(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByStatus(CategoryStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void reset() => state = const CategoryFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered + sorted category list
// ─────────────────────────────────────────────

/// Returns the filtered, sorted category list for the admin list page.
final filteredCategoryListProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoryListProvider).valueOrNull ?? [];
  final filter = ref.watch(categoryFilterProvider);

  var result = all.where((c) {
    switch (filter.statusFilter) {
      case CategoryStatusFilter.active:
        if (!c.isActive) return false;
      case CategoryStatusFilter.inactive:
        if (c.isActive) return false;
      case CategoryStatusFilter.all:
        break;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.slug.toLowerCase().contains(q);
    }
    return true;
  }).toList();

  result.sort((a, b) {
    final s = a.sortOrder.compareTo(b.sortOrder);
    return s != 0 ? s : a.name.compareTo(b.name);
  });

  return result;
});

/// Active categories only (used by KC-App customer views and design filtering).
final activeCategoryListProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoryListProvider).valueOrNull ?? [];
  return all.where((c) => c.isActive).toList(growable: false)..sort((a, b) {
    final s = a.sortOrder.compareTo(b.sortOrder);
    return s != 0 ? s : a.name.compareTo(b.name);
  });
});

// ─────────────────────────────────────────────
// Mutation notifier (admin CRUD)
// ─────────────────────────────────────────────

/// Exposes admin CRUD operations for categories.
/// Each method calls Firestore and invalidates [categoryListProvider] on success.
final categoryMutationProvider =
    NotifierProvider<CategoryMutationNotifier, AsyncValue<void>>(
      CategoryMutationNotifier.new,
    );

class CategoryMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CategoryFirestoreRepository get _repo => ref.read(categoryRepositoryProvider);

  Future<void> create(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createCategory(category));
    if (!state.hasError) ref.invalidate(categoryListProvider);
  }

  Future<void> update(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateCategory(category));
    if (!state.hasError) ref.invalidate(categoryListProvider);
  }

  Future<void> setActive(String categoryId, bool isActive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.setCategoryActiveStatus(categoryId, isActive),
    );
    if (!state.hasError) ref.invalidate(categoryListProvider);
  }

  Future<void> reorder(List<CategoryModel> reordered) async {
    final updated = List<CategoryModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (final cat in updated) {
        await _repo.updateCategory(cat);
      }
    });
    if (!state.hasError) ref.invalidate(categoryListProvider);
  }
}
