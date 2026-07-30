import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/pagination/paginated_state.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/stitching/data/repositories/stitching_order_firestore_repository.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_admin/src/features/stitching/domain/models/stitching_status_mutation_state.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final stitchingRepositoryProvider = Provider<StitchingOrderFirestoreRepository>(
  (ref) {
    return StitchingOrderFirestoreRepository(
      firestore: ref.watch(firebaseFirestoreProvider),
    );
  },
);

// ─────────────────────────────────────────────
// Order filter state
// ─────────────────────────────────────────────

class OrderFilterState {
  const OrderFilterState({this.searchQuery = '', this.statusFilter});
  final String searchQuery;
  final StitchingOrderStatus? statusFilter;

  OrderFilterState copyWith({
    String? searchQuery,
    Object? statusFilter = _sentinel,
  }) => OrderFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: statusFilter == _sentinel
        ? this.statusFilter
        : statusFilter as StitchingOrderStatus?,
  );
}

const _sentinel = Object();

// ─────────────────────────────────────────────
// Admin order list — live stream & paginated
// ─────────────────────────────────────────────

final adminOrderListProvider = StreamProvider<List<StitchingOrderModel>>((ref) {
  // Re-subscribe whenever Firebase auth state changes (e.g. login/logout)
  ref.watch(firebaseAuthStateProvider);
  return ref.watch(stitchingRepositoryProvider).watchAdminOrders();
});

/// Fast aggregate status counts for summary header (10k+ scalability)
final stitchingStatusCountsProvider = FutureProvider<({int total, int requested, int accepted, int completed})>((ref) async {
  return ref.watch(stitchingRepositoryProvider).fetchStatusCounts();
});

// ─────────────────────────────────────────────
// Paginated Stitching Order Notifier
// ─────────────────────────────────────────────

final paginatedStitchingOrdersProvider =
    StateNotifierProvider<PaginatedStitchingOrdersNotifier, PaginatedState<StitchingOrderModel>>(
  (ref) {
    return PaginatedStitchingOrdersNotifier(
      repository: ref.watch(stitchingRepositoryProvider),
    );
  },
);

class PaginatedStitchingOrdersNotifier extends StateNotifier<PaginatedState<StitchingOrderModel>> {
  PaginatedStitchingOrdersNotifier({required this.repository})
      : super(const PaginatedState()) {
    fetchInitial();
  }

  final StitchingOrderFirestoreRepository repository;
  StitchingOrderStatus? _currentStatus;
  String _currentQuery = '';

  Future<void> fetchInitial({StitchingOrderStatus? status, String query = ''}) async {
    _currentStatus = status;
    _currentQuery = query.trim();

    state = state.copyWith(isLoading: true, errorMessage: null, items: [], lastDocId: null, hasMore: true);

    try {
      final res = await repository.fetchPaginatedOrders(
        limit: 20,
        status: _currentStatus?.name,
      );

      var filtered = res.items;
      if (_currentStatus != null) {
        filtered = filtered.where((o) => o.status == _currentStatus).toList();
      }

      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((o) =>
          o.orderNumber.toLowerCase().contains(q) ||
          o.designReferences.any((d) => d.designName.toLowerCase().contains(q)) ||
          (o.notes?.toLowerCase().contains(q) ?? false)
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
      final res = await repository.fetchPaginatedOrders(
        limit: 20,
        startAfterId: state.lastDocId,
        status: _currentStatus?.name,
      );

      var filtered = res.items;
      if (_currentStatus != null) {
        filtered = filtered.where((o) => o.status == _currentStatus).toList();
      }

      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        filtered = filtered.where((o) =>
          o.orderNumber.toLowerCase().contains(q) ||
          o.designReferences.any((d) => d.designName.toLowerCase().contains(q)) ||
          (o.notes?.toLowerCase().contains(q) ?? false)
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
    await fetchInitial(status: _currentStatus, query: _currentQuery);
  }
}

// ─────────────────────────────────────────────
// Order filter notifier (admin)
// ─────────────────────────────────────────────

final orderFilterProvider =
    NotifierProvider<OrderFilterNotifier, OrderFilterState>(
      OrderFilterNotifier.new,
    );

class OrderFilterNotifier extends Notifier<OrderFilterState> {
  @override
  OrderFilterState build() => const OrderFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByStatus(StitchingOrderStatus? s) =>
      state = state.copyWith(statusFilter: s);

  void reset() => state = const OrderFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered admin order list
// ─────────────────────────────────────────────

final filteredOrderListProvider = Provider<List<StitchingOrderModel>>((ref) {
  final all = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  final filter = ref.watch(orderFilterProvider);

  var result = all.where((o) {
    if (filter.statusFilter != null && o.status != filter.statusFilter) {
      return false;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return o.orderNumber.toLowerCase().contains(q) ||
          o.designReferences.any(
            (d) => d.designName.toLowerCase().contains(q),
          ) ||
          (o.notes?.toLowerCase().contains(q) ?? false);
    }
    return true;
  }).toList();

  result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return result;
});

// ─────────────────────────────────────────────
// Customer order list — live stream
// ─────────────────────────────────────────────

final customerOrderListProvider =
    StreamProvider.family<List<StitchingOrderModel>, String>((ref, customerId) {
      return ref
          .watch(stitchingRepositoryProvider)
          .watchCustomerOrders('default', customerId);
    });

// ─────────────────────────────────────────────
// Row-Level Stitching Status Mutation Notifier
// ─────────────────────────────────────────────

final stitchingStatusMutationProvider =
    NotifierProvider<
      StitchingStatusMutationNotifier,
      StitchingStatusMutationState
    >(StitchingStatusMutationNotifier.new);

class StitchingStatusMutationNotifier
    extends Notifier<StitchingStatusMutationState> {
  @override
  StitchingStatusMutationState build() => const StitchingStatusMutationState();

  Future<bool> updateStatus({
    required StitchingOrderModel order,
    required StitchingOrderStatus newStatus,
    required String updatedBy,
    String? note,
  }) async {
    final updatedRequests = Map<String, RowMutationState>.from(state.requests);
    updatedRequests[order.id] = const RowMutationState(
      status: MutationStatus.loading,
    );
    state = state.copyWith(requests: updatedRequests);

    try {
      final repo = ref.read(stitchingRepositoryProvider);
      await repo.updateOrderStatusWithHistory(
        orderId: order.id,
        newStatus: newStatus,
        note: note,
        updatedBy: updatedBy,
      );

      ref.invalidate(adminOrderListProvider);
      ref.invalidate(stitchingStatusCountsProvider);
      ref.invalidate(stitchingOrderHistoryProvider(order.id));
      await ref.read(paginatedStitchingOrdersProvider.notifier).refresh();

      final successRequests = Map<String, RowMutationState>.from(
        state.requests,
      );
      successRequests[order.id] = const RowMutationState(
        status: MutationStatus.success,
      );
      state = state.copyWith(requests: successRequests);
      return true;
    } catch (e) {
      final failRequests = Map<String, RowMutationState>.from(state.requests);
      failRequests[order.id] = RowMutationState(
        status: MutationStatus.failure,
        errorMessage: e.toString(),
      );
      state = state.copyWith(requests: failRequests);
      return false;
    }
  }
}

// ─────────────────────────────────────────────
// Admin Mutation notifier for order creation
// ─────────────────────────────────────────────

final stitchingMutationProvider =
    NotifierProvider<StitchingMutationNotifier, AsyncValue<void>>(
      StitchingMutationNotifier.new,
    );

class StitchingMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  StitchingOrderFirestoreRepository get _repo =>
      ref.read(stitchingRepositoryProvider);

  Future<void> createOrder({
    required StitchingOrderModel order,
    required String initialNote,
    required String createdBy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.createOrderWithHistory(
        order: order,
        initialNote: initialNote,
        createdBy: createdBy,
      ),
    );
    if (!state.hasError) ref.invalidate(adminOrderListProvider);
  }

  Future<void> create(StitchingOrderModel order) async {
    await createOrder(
      order: order,
      initialNote: 'Order created.',
      createdBy: order.createdBy ?? 'admin',
    );
  }

  Future<void> update(StitchingOrderModel order) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateOrder(order));
    if (!state.hasError) ref.invalidate(adminOrderListProvider);
  }
}

/// Alias so pages referencing stitchingOrderMutationProvider still compile.
final stitchingOrderMutationProvider = stitchingMutationProvider;

/// Provider to fetch timeline history for a specific stitching order from Firestore.
final stitchingOrderHistoryProvider =
    FutureProvider.family<List<StitchingOrderHistoryModel>, String>(
  (ref, orderId) async {
    return ref.watch(stitchingRepositoryProvider).fetchOrderHistory(orderId);
  },
);
