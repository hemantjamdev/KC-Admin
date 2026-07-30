import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_admin/src/core/pagination/paginated_state.dart';
import 'package:kc_admin/src/core/providers/firebase_providers.dart';
import 'package:kc_admin/src/features/customer/data/datasources/customer_firestore_data_source.dart';
import 'package:kc_admin/src/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:kc_admin/src/features/customer/domain/models/customer_model.dart';
import 'package:kc_admin/src/features/customer/domain/repositories/customer_repository.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final customerDataSourceProvider = Provider<CustomerFirestoreDataSource>((ref) {
  return CustomerFirestoreDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(
    dataSource: ref.watch(customerDataSourceProvider),
  );
});

// ─────────────────────────────────────────────
// Admin: Customer list
// ─────────────────────────────────────────────

class CustomerFilterState {
  const CustomerFilterState({this.searchQuery = '', this.isActiveFilter});
  final String searchQuery;
  final bool? isActiveFilter;

  CustomerFilterState copyWith({
    String? searchQuery,
    Object? isActiveFilter = _sentinel,
  }) => CustomerFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    isActiveFilter: isActiveFilter == _sentinel
        ? this.isActiveFilter
        : isActiveFilter as bool?,
  );
}

const _sentinel = Object();

final customerFilterProvider =
    NotifierProvider<CustomerFilterNotifier, CustomerFilterState>(
      CustomerFilterNotifier.new,
    );

class CustomerFilterNotifier extends Notifier<CustomerFilterState> {
  @override
  CustomerFilterState build() => const CustomerFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByActive(bool? isActive) =>
      state = state.copyWith(isActiveFilter: isActive);

  void reset() => state = const CustomerFilterState();
}

/// Admin customer list with filter applied.
final customerListProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final filter = ref.watch(customerFilterProvider);

  return ref
      .watch(customerRepositoryProvider)
      .getCustomersForAdmin(
        isActive: filter.isActiveFilter,
        searchQuery: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
      );
});

// ─────────────────────────────────────────────
// Paginated Customers Notifier
// ─────────────────────────────────────────────

final paginatedCustomersProvider =
    StateNotifierProvider<PaginatedCustomersNotifier, PaginatedState<CustomerModel>>(
  (ref) {
    return PaginatedCustomersNotifier(
      repository: ref.watch(customerRepositoryProvider),
    );
  },
);

class PaginatedCustomersNotifier extends StateNotifier<PaginatedState<CustomerModel>> {
  PaginatedCustomersNotifier({required this.repository})
      : super(const PaginatedState()) {
    fetchInitial();
  }

  final CustomerRepository repository;
  String _currentQuery = '';

  Future<void> fetchInitial({String query = ''}) async {
    _currentQuery = query.trim();

    state = state.copyWith(isLoading: true, errorMessage: null, items: [], lastDocId: null, hasMore: true);

    try {
      final res = await repository.fetchPaginatedCustomers(limit: 20);

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        final digitsOnly = q.replaceAll(RegExp(r'\D'), '');

        filtered = filtered.where((c) {
          final inName = c.displayName.toLowerCase().contains(q);
          final inEmail = c.email != null && c.email!.toLowerCase().contains(q);
          final inPhone = c.phone != null &&
              (c.phone!.toLowerCase().contains(q) ||
                  (digitsOnly.isNotEmpty &&
                      c.phone!.replaceAll(RegExp(r'\D'), '').contains(digitsOnly)));
          return inName || inEmail || inPhone;
        }).toList();
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
      final res = await repository.fetchPaginatedCustomers(
        limit: 20,
        startAfterId: state.lastDocId,
      );

      var filtered = res.items;
      if (_currentQuery.isNotEmpty) {
        final q = _currentQuery.toLowerCase();
        final digitsOnly = q.replaceAll(RegExp(r'\D'), '');

        filtered = filtered.where((c) {
          final inName = c.displayName.toLowerCase().contains(q);
          final inEmail = c.email != null && c.email!.toLowerCase().contains(q);
          final inPhone = c.phone != null &&
              (c.phone!.toLowerCase().contains(q) ||
                  (digitsOnly.isNotEmpty &&
                      c.phone!.replaceAll(RegExp(r'\D'), '').contains(digitsOnly)));
          return inName || inEmail || inPhone;
        }).toList();
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
    await fetchInitial(query: _currentQuery);
  }
}

/// Customer details by ID.
final customerDetailsProvider = FutureProvider.family<CustomerModel?, String>((
  ref,
  customerId,
) {
  return ref.watch(customerRepositoryProvider).getCustomerById(customerId);
});

// ─────────────────────────────────────────────
// Customer mutation notifier (admin)
// ─────────────────────────────────────────────

final customerMutationProvider =
    NotifierProvider<CustomerMutationNotifier, AsyncValue<void>>(
      CustomerMutationNotifier.new,
    );

class CustomerMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CustomerRepository get _repo => ref.read(customerRepositoryProvider);

  Future<void> create(CustomerModel customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createCustomer(customer));
    if (!state.hasError) ref.invalidate(customerListProvider);
  }

  Future<void> update(CustomerModel customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateCustomer(customer));
    if (!state.hasError) {
      ref.invalidate(customerListProvider);
      ref.invalidate(customerDetailsProvider(customer.id));
    }
  }

  Future<void> setActive(
    String customerId,
    bool isActive,
    String updatedBy,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.setCustomerActiveStatus(customerId, isActive, updatedBy),
    );
    if (!state.hasError) {
      ref.invalidate(customerListProvider);
      ref.invalidate(customerDetailsProvider(customerId));
    }
  }
}
