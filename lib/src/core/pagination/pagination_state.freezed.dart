// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagination_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaginationState<T> {
  List<T> get items => throw _privateConstructorUsedError;
  bool get isInitialLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  AppFailure? get failure => throw _privateConstructorUsedError;

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationStateCopyWith<T, PaginationState<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationStateCopyWith<T, $Res> {
  factory $PaginationStateCopyWith(
    PaginationState<T> value,
    $Res Function(PaginationState<T>) then,
  ) = _$PaginationStateCopyWithImpl<T, $Res, PaginationState<T>>;
  @useResult
  $Res call({
    List<T> items,
    bool isInitialLoading,
    bool isLoadingMore,
    bool isRefreshing,
    bool hasMore,
    String? nextCursor,
    AppFailure? failure,
  });

  $AppFailureCopyWith<$Res>? get failure;
}

/// @nodoc
class _$PaginationStateCopyWithImpl<T, $Res, $Val extends PaginationState<T>>
    implements $PaginationStateCopyWith<T, $Res> {
  _$PaginationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isInitialLoading = null,
    Object? isLoadingMore = null,
    Object? isRefreshing = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
    Object? failure = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<T>,
            isInitialLoading: null == isInitialLoading
                ? _value.isInitialLoading
                : isInitialLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRefreshing: null == isRefreshing
                ? _value.isRefreshing
                : isRefreshing // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            failure: freezed == failure
                ? _value.failure
                : failure // ignore: cast_nullable_to_non_nullable
                      as AppFailure?,
          )
          as $Val,
    );
  }

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res>? get failure {
    if (_value.failure == null) {
      return null;
    }

    return $AppFailureCopyWith<$Res>(_value.failure!, (value) {
      return _then(_value.copyWith(failure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaginationStateImplCopyWith<T, $Res>
    implements $PaginationStateCopyWith<T, $Res> {
  factory _$$PaginationStateImplCopyWith(
    _$PaginationStateImpl<T> value,
    $Res Function(_$PaginationStateImpl<T>) then,
  ) = __$$PaginationStateImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({
    List<T> items,
    bool isInitialLoading,
    bool isLoadingMore,
    bool isRefreshing,
    bool hasMore,
    String? nextCursor,
    AppFailure? failure,
  });

  @override
  $AppFailureCopyWith<$Res>? get failure;
}

/// @nodoc
class __$$PaginationStateImplCopyWithImpl<T, $Res>
    extends _$PaginationStateCopyWithImpl<T, $Res, _$PaginationStateImpl<T>>
    implements _$$PaginationStateImplCopyWith<T, $Res> {
  __$$PaginationStateImplCopyWithImpl(
    _$PaginationStateImpl<T> _value,
    $Res Function(_$PaginationStateImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isInitialLoading = null,
    Object? isLoadingMore = null,
    Object? isRefreshing = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
    Object? failure = freezed,
  }) {
    return _then(
      _$PaginationStateImpl<T>(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<T>,
        isInitialLoading: null == isInitialLoading
            ? _value.isInitialLoading
            : isInitialLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRefreshing: null == isRefreshing
            ? _value.isRefreshing
            : isRefreshing // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        failure: freezed == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as AppFailure?,
      ),
    );
  }
}

/// @nodoc

class _$PaginationStateImpl<T> implements _PaginationState<T> {
  const _$PaginationStateImpl({
    final List<T> items = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.nextCursor,
    this.failure,
  }) : _items = items;

  final List<T> _items;
  @override
  @JsonKey()
  List<T> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isInitialLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? nextCursor;
  @override
  final AppFailure? failure;

  @override
  String toString() {
    return 'PaginationState<$T>(items: $items, isInitialLoading: $isInitialLoading, isLoadingMore: $isLoadingMore, isRefreshing: $isRefreshing, hasMore: $hasMore, nextCursor: $nextCursor, failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationStateImpl<T> &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isInitialLoading, isInitialLoading) ||
                other.isInitialLoading == isInitialLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    isInitialLoading,
    isLoadingMore,
    isRefreshing,
    hasMore,
    nextCursor,
    failure,
  );

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationStateImplCopyWith<T, _$PaginationStateImpl<T>> get copyWith =>
      __$$PaginationStateImplCopyWithImpl<T, _$PaginationStateImpl<T>>(
        this,
        _$identity,
      );
}

abstract class _PaginationState<T> implements PaginationState<T> {
  const factory _PaginationState({
    final List<T> items,
    final bool isInitialLoading,
    final bool isLoadingMore,
    final bool isRefreshing,
    final bool hasMore,
    final String? nextCursor,
    final AppFailure? failure,
  }) = _$PaginationStateImpl<T>;

  @override
  List<T> get items;
  @override
  bool get isInitialLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get isRefreshing;
  @override
  bool get hasMore;
  @override
  String? get nextCursor;
  @override
  AppFailure? get failure;

  /// Create a copy of PaginationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationStateImplCopyWith<T, _$PaginationStateImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
