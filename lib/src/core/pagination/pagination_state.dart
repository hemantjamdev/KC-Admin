import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/app_failure.dart';

part 'pagination_state.freezed.dart';

@freezed
class PaginationState<T> with _$PaginationState<T> {
  const factory PaginationState({
    @Default([]) List<T> items,
    @Default(false) bool isInitialLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    @Default(true) bool hasMore,
    String? nextCursor,
    AppFailure? failure,
  }) = _PaginationState<T>;
}
