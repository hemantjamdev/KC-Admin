import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/pagination/paginated_state.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/category/application/providers/category_providers.dart';
import 'package:kc_admin/src/features/design/data/repositories/design_firestore_repository.dart';
import 'package:kc_admin/src/features/design/domain/models/design_availability_model.dart';
import 'package:kc_admin/src/features/design/domain/models/design_model.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final designRepositoryProvider = Provider<DesignFirestoreRepository>((ref) {
  return DesignFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// ─────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────

enum DesignStatusFilter { all, active, inactive }

enum AvailabilityFilter { all, available, unavailable, hidden, notConfigured }

class DesignFilterState {
  const DesignFilterState({
    this.searchQuery = '',
    this.statusFilter = DesignStatusFilter.all,
    this.selectedCategoryId,
    this.availabilityFilter = AvailabilityFilter.all,
    this.filterBranchId,
  });
  final String searchQuery;
  final DesignStatusFilter statusFilter;
  final String? selectedCategoryId;
  final AvailabilityFilter availabilityFilter;
  final String? filterBranchId;

  DesignFilterState copyWith({
    String? searchQuery,
    DesignStatusFilter? statusFilter,
    Object? selectedCategoryId = _sentinel,
    AvailabilityFilter? availabilityFilter,
    Object? filterBranchId = _sentinel,
  }) => DesignFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: statusFilter ?? this.statusFilter,
    selectedCategoryId: selectedCategoryId == _sentinel
        ? this.selectedCategoryId
        : selectedCategoryId as String?,
    availabilityFilter: availabilityFilter ?? this.availabilityFilter,
    filterBranchId: filterBranchId == _sentinel
        ? this.filterBranchId
        : filterBranchId as String?,
  );
}

const _sentinel = Object();

// ─────────────────────────────────────────────
// Design list — live stream for selected boutique
// ─────────────────────────────────────────────

final designListProvider = StreamProvider<List<DesignModel>>((ref) {
  return ref.watch(designRepositoryProvider).watchDesigns('boutique_01');
});

final paginatedDesignsProvider =
    StateNotifierProvider<PaginatedDesignsNotifier, PaginatedState<DesignModel>>(
  (ref) {
    return PaginatedDesignsNotifier(
      repository: ref.watch(designRepositoryProvider),
    );
  },
);

class PaginatedDesignsNotifier extends StateNotifier<PaginatedState<DesignModel>> {
  PaginatedDesignsNotifier({required this.repository})
      : super(const PaginatedState()) {
    fetchInitial();
  }

  final DesignFirestoreRepository repository;
  String? _currentCategoryId;
  String _currentQuery = '';

  Future<void> fetchInitial({String? categoryId, String query = ''}) async {
    _currentCategoryId = categoryId;
    _currentQuery = query.trim();

    state = state.copyWith(isLoading: true, errorMessage: null, items: [], lastDocId: null, hasMore: true);

    try {
      final res = await repository.fetchPaginatedDesigns(
        limit: 20,
        categoryId: _currentCategoryId,
      );

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q)) ||
          d.searchKeywords.any((k) => k.toLowerCase().contains(q))
        ).toList();
      }

      state = state.copyWith(
        items: filtered,
        isLoading: false,
        lastDocId: res.lastDocId,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final res = await repository.fetchPaginatedDesigns(
        limit: 20,
        startAfterId: state.lastDocId,
        categoryId: _currentCategoryId,
      );

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q)) ||
          d.searchKeywords.any((k) => k.toLowerCase().contains(q))
        ).toList();
      }

      state = state.copyWith(
        items: [...state.items, ...filtered],
        isLoadingMore: false,
        lastDocId: res.lastDocId,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    await fetchInitial(categoryId: _currentCategoryId, query: _currentQuery);
  }
}

// ─────────────────────────────────────────────
// Design availability — per boutique
// ─────────────────────────────────────────────

final designAvailabilityListProvider =
    FutureProvider<List<DesignAvailabilityModel>>((ref) async {
      // Availability is loaded per-page when needed (design_availability_page).
      // This provider is a placeholder — pages that need availability load it directly.
      return const [];
    });

// ─────────────────────────────────────────────
// Filter notifier
// ─────────────────────────────────────────────

final designFilterProvider =
    NotifierProvider<DesignFilterNotifier, DesignFilterState>(
      DesignFilterNotifier.new,
    );

class DesignFilterNotifier extends Notifier<DesignFilterState> {
  @override
  DesignFilterState build() => const DesignFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByStatus(DesignStatusFilter f) =>
      state = state.copyWith(statusFilter: f);

  void filterByCategory(String? categoryId) =>
      state = state.copyWith(selectedCategoryId: categoryId);

  void filterByAvailability(AvailabilityFilter f, {String? branchId}) =>
      state = state.copyWith(availabilityFilter: f, filterBranchId: branchId);

  void reset() => state = const DesignFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered design list
// ─────────────────────────────────────────────

final filteredDesignListProvider = Provider<List<DesignModel>>((ref) {
  final all = ref.watch(designListProvider).valueOrNull ?? [];
  final filter = ref.watch(designFilterProvider);

  var result = all.where((d) {
    switch (filter.statusFilter) {
      case DesignStatusFilter.active:
        if (!d.isActive) return false;
      case DesignStatusFilter.inactive:
        if (d.isActive) return false;
      case DesignStatusFilter.all:
        break;
    }
    if (filter.selectedCategoryId != null &&
        d.categoryId != filter.selectedCategoryId) {
      return false;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.slug.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q)) ||
          d.searchKeywords.any((k) => k.toLowerCase().contains(q));
    }
    return true;
  }).toList();

  result.sort((a, b) {
    final s = a.sortOrder.compareTo(b.sortOrder);
    return s != 0 ? s : a.name.compareTo(b.name);
  });

  return result;
});

/// Active designs for a given branch — used by customer-facing pages.
final availableDesignsForBranchProvider =
    Provider.family<List<DesignModel>, String>((ref, branchId) {
      final all = ref.watch(designListProvider).valueOrNull ?? [];
      final avail = ref.watch(designAvailabilityListProvider).valueOrNull ?? [];
      final activeCategories = ref.watch(activeCategoryListProvider);
      final activeCategoryIds = activeCategories.map((c) => c.id).toSet();
      final now = DateTime.now();

      return all
          .where((d) {
            if (!d.isActive) return false;
            if (!activeCategoryIds.contains(d.categoryId)) return false;
            try {
              final a = avail.firstWhere(
                (a) => a.branchId == branchId && a.designId == d.id,
              );
              if (a.status != AvailabilityStatus.available) return false;
              if (a.availableFrom != null && now.isBefore(a.availableFrom!)) {
                return false;
              }
              if (a.availableUntil != null && now.isAfter(a.availableUntil!)) {
                return false;
              }
              return true;
            } catch (_) {
              return false;
            }
          })
          .toList(growable: false);
    });

// ─────────────────────────────────────────────
// Design details — family by ID
// ─────────────────────────────────────────────

final designDetailsProvider = Provider.family<DesignModel?, String>((
  ref,
  designId,
) {
  final all = ref.watch(designListProvider).valueOrNull ?? [];
  try {
    return all.firstWhere((d) => d.id == designId);
  } catch (_) {
    return null;
  }
});

// ─────────────────────────────────────────────
// Mutation notifier (admin)
// ─────────────────────────────────────────────

final designMutationProvider =
    NotifierProvider<DesignMutationNotifier, AsyncValue<void>>(
      DesignMutationNotifier.new,
    );

class DesignMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  DesignFirestoreRepository get _repo => ref.read(designRepositoryProvider);

  Future<void> create(DesignModel design) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createDesign(design));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> update(DesignModel design) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateDesign(design));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> upsertAvailability({
    required String boutiqueId,
    required String branchId,
    required String designId,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.upsertAvailability(
        boutiqueId: boutiqueId,
        branchId: branchId,
        designId: designId,
        status: status,
      ),
    );
  }

  Future<void> toggleStatus(String designId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.toggleDesignStatus(designId));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> delete(String designId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deleteDesign(designId));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> reorder(List<DesignModel> reordered) async {
    final updated = List<DesignModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (final d in updated) {
        await _repo.updateDesign(d);
      }
    });
    if (!state.hasError) ref.invalidate(designListProvider);
  }
}
