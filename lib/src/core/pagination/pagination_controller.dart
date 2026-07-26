import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../result/app_result.dart';
import 'paginated_result.dart';
import 'pagination_state.dart';

abstract class PaginationController<T>
    extends StateNotifier<PaginationState<T>> {
  PaginationController() : super(PaginationState<T>());

  Future<AppResult<PaginatedResult<T>>> fetchPage(String? cursor);

  Future<void> loadInitial() async {
    if (state.isInitialLoading || state.isLoadingMore || state.isRefreshing) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, failure: null);

    final result = await fetchPage(null);

    result.when(
      success: (paginatedResult) {
        state = state.copyWith(
          items: paginatedResult.items,
          nextCursor: paginatedResult.nextCursor,
          hasMore: paginatedResult.hasMore,
          isInitialLoading: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(isInitialLoading: false, failure: failure);
      },
    );
  }

  Future<void> refresh() async {
    if (state.isRefreshing || state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isRefreshing: true, failure: null);

    final result = await fetchPage(null);

    result.when(
      success: (paginatedResult) {
        state = state.copyWith(
          items: paginatedResult.items,
          nextCursor: paginatedResult.nextCursor,
          hasMore: paginatedResult.hasMore,
          isRefreshing: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(isRefreshing: false, failure: failure);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isInitialLoading ||
        state.isRefreshing ||
        !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, failure: null);

    final result = await fetchPage(state.nextCursor);

    result.when(
      success: (paginatedResult) {
        final existingIds = state.items.toSet();
        final newItems = paginatedResult.items
            .where((item) => !existingIds.contains(item))
            .toList();

        state = state.copyWith(
          items: [...state.items, ...newItems],
          nextCursor: paginatedResult.nextCursor,
          hasMore: paginatedResult.hasMore,
          isLoadingMore: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(isLoadingMore: false, failure: failure);
      },
    );
  }
}
