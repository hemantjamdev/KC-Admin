import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

@freezed
class PaginatedResult<T> with _$PaginatedResult<T> {
  const factory PaginatedResult({
    required List<T> items,
    String? nextCursor,
    required bool hasMore,
  }) = _PaginatedResult<T>;
}
