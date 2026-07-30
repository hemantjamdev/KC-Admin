import 'package:flutter/foundation.dart';

/// Generic state container for cursor-based infinite scroll pagination.
@immutable
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastDocId,
    this.errorMessage,
  });

  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? lastDocId;
  final String? errorMessage;

  bool get isEmpty => !isLoading && items.isEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? lastDocId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDocId: lastDocId == _sentinel ? this.lastDocId : lastDocId as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();
}
