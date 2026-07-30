import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/design/application/providers/design_providers.dart';
import 'package:kc_admin/src/features/design/domain/models/design_model.dart';
import 'package:kc_admin/src/features/section/data/repositories/section_firestore_repository.dart';
import 'package:kc_admin/src/features/section/domain/models/section_item_model.dart';
import 'package:kc_admin/src/features/section/domain/models/section_model.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final sectionRepositoryProvider = Provider<SectionFirestoreRepository>((ref) {
  return SectionFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// ─────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────

enum SectionStatusFilter { all, active, inactive }

class SectionFilterState {
  const SectionFilterState({
    this.searchQuery = '',
    this.statusFilter = SectionStatusFilter.all,
    this.typeFilter,
  });
  final String searchQuery;
  final SectionStatusFilter statusFilter;
  final SectionType? typeFilter;

  SectionFilterState copyWith({
    String? searchQuery,
    SectionStatusFilter? statusFilter,
    Object? typeFilter = _sentinel,
  }) {
    return SectionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter == _sentinel
          ? this.typeFilter
          : typeFilter as SectionType?,
    );
  }
}

const _sentinel = Object();

// ─────────────────────────────────────────────
// Section list — live stream
// ─────────────────────────────────────────────

final sectionListProvider = StreamProvider<List<SectionModel>>((ref) {
  return ref.watch(sectionRepositoryProvider).watchSections('boutique_01');
});

// ─────────────────────────────────────────────
// Filter notifier
// ─────────────────────────────────────────────

final sectionFilterProvider =
    NotifierProvider<SectionFilterNotifier, SectionFilterState>(
      SectionFilterNotifier.new,
    );

class SectionFilterNotifier extends Notifier<SectionFilterState> {
  @override
  SectionFilterState build() => const SectionFilterState();

  void search(String query) =>
      state = state.copyWith(searchQuery: query.trim());

  void filterByStatus(SectionStatusFilter f) =>
      state = state.copyWith(statusFilter: f);

  void filterByType(SectionType? t) => state = state.copyWith(typeFilter: t);

  void reset() => state = const SectionFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered section list
// ─────────────────────────────────────────────

final filteredSectionListProvider = Provider<List<SectionModel>>((ref) {
  final all = ref.watch(sectionListProvider).valueOrNull ?? [];
  final filter = ref.watch(sectionFilterProvider);

  var result = all.where((s) {
    switch (filter.statusFilter) {
      case SectionStatusFilter.active:
        if (!s.isActive) return false;
      case SectionStatusFilter.inactive:
        if (s.isActive) return false;
      case SectionStatusFilter.all:
        break;
    }
    if (filter.typeFilter != null && s.type != filter.typeFilter) return false;
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return s.title.toLowerCase().contains(q);
    }
    return true;
  }).toList();

  result.sort((a, b) {
    final sortCompare = a.sortOrder.compareTo(b.sortOrder);
    return sortCompare != 0 ? sortCompare : a.title.compareTo(b.title);
  });

  return result;
});

/// Active sections only (customer views).
final activeSectionListProvider = Provider<List<SectionModel>>((ref) {
  final all = ref.watch(sectionListProvider).valueOrNull ?? [];
  return all.where((s) => s.isActive).toList(growable: false)
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
});

// ─────────────────────────────────────────────
// Section details (items)  — family provider
// ─────────────────────────────────────────────

final sectionItemsProvider =
    FutureProvider.family<List<SectionItemModel>, String>((
      ref,
      sectionId,
    ) async {
      return const [];
    });

// ─────────────────────────────────────────────
// Design resolution for section picker
// ─────────────────────────────────────────────

/// Returns the [DesignModel] for a given designId, or null if not loaded.
final designByIdProvider = Provider.family<DesignModel?, String>((
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
// Mutation notifier
// ─────────────────────────────────────────────

final sectionMutationProvider =
    NotifierProvider<SectionMutationNotifier, AsyncValue<void>>(
      SectionMutationNotifier.new,
    );

class SectionMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SectionFirestoreRepository get _repo => ref.read(sectionRepositoryProvider);

  Future<void> create(SectionModel section) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createSection(section));
    if (!state.hasError) ref.invalidate(sectionListProvider);
  }

  Future<void> update(SectionModel section) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateSection(section));
    if (!state.hasError) ref.invalidate(sectionListProvider);
  }

  Future<void> reorder(List<SectionModel> reordered) async {
    final updated = List<SectionModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (final s in updated) {
        await _repo.updateSection(s);
      }
    });
    if (!state.hasError) ref.invalidate(sectionListProvider);
  }

  Future<void> delete(String sectionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deleteSection(sectionId));
    if (!state.hasError) ref.invalidate(sectionListProvider);
  }

  Future<void> saveSectionItems(
    String sectionId,
    List<String> orderedDesignIds,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.saveSectionItems(sectionId, orderedDesignIds),
    );
  }
}
