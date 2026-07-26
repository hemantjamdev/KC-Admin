// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppResult<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppFailure failure) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppFailure failure)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppResultSuccess<T> value) success,
    required TResult Function(AppResultFailure<T> value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppResultSuccess<T> value)? success,
    TResult? Function(AppResultFailure<T> value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppResultSuccess<T> value)? success,
    TResult Function(AppResultFailure<T> value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppResultCopyWith<T, $Res> {
  factory $AppResultCopyWith(
    AppResult<T> value,
    $Res Function(AppResult<T>) then,
  ) = _$AppResultCopyWithImpl<T, $Res, AppResult<T>>;
}

/// @nodoc
class _$AppResultCopyWithImpl<T, $Res, $Val extends AppResult<T>>
    implements $AppResultCopyWith<T, $Res> {
  _$AppResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AppResultSuccessImplCopyWith<T, $Res> {
  factory _$$AppResultSuccessImplCopyWith(
    _$AppResultSuccessImpl<T> value,
    $Res Function(_$AppResultSuccessImpl<T>) then,
  ) = __$$AppResultSuccessImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$AppResultSuccessImplCopyWithImpl<T, $Res>
    extends _$AppResultCopyWithImpl<T, $Res, _$AppResultSuccessImpl<T>>
    implements _$$AppResultSuccessImplCopyWith<T, $Res> {
  __$$AppResultSuccessImplCopyWithImpl(
    _$AppResultSuccessImpl<T> _value,
    $Res Function(_$AppResultSuccessImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _$AppResultSuccessImpl<T>(
        freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as T,
      ),
    );
  }
}

/// @nodoc

class _$AppResultSuccessImpl<T> implements AppResultSuccess<T> {
  const _$AppResultSuccessImpl(this.data);

  @override
  final T data;

  @override
  String toString() {
    return 'AppResult<$T>.success(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppResultSuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppResultSuccessImplCopyWith<T, _$AppResultSuccessImpl<T>> get copyWith =>
      __$$AppResultSuccessImplCopyWithImpl<T, _$AppResultSuccessImpl<T>>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppResultSuccess<T> value) success,
    required TResult Function(AppResultFailure<T> value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppResultSuccess<T> value)? success,
    TResult? Function(AppResultFailure<T> value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppResultSuccess<T> value)? success,
    TResult Function(AppResultFailure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class AppResultSuccess<T> implements AppResult<T> {
  const factory AppResultSuccess(final T data) = _$AppResultSuccessImpl<T>;

  T get data;

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppResultSuccessImplCopyWith<T, _$AppResultSuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppResultFailureImplCopyWith<T, $Res> {
  factory _$$AppResultFailureImplCopyWith(
    _$AppResultFailureImpl<T> value,
    $Res Function(_$AppResultFailureImpl<T>) then,
  ) = __$$AppResultFailureImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$AppResultFailureImplCopyWithImpl<T, $Res>
    extends _$AppResultCopyWithImpl<T, $Res, _$AppResultFailureImpl<T>>
    implements _$$AppResultFailureImplCopyWith<T, $Res> {
  __$$AppResultFailureImplCopyWithImpl(
    _$AppResultFailureImpl<T> _value,
    $Res Function(_$AppResultFailureImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$AppResultFailureImpl<T>(
        null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as AppFailure,
      ),
    );
  }

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res> get failure {
    return $AppFailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$AppResultFailureImpl<T> implements AppResultFailure<T> {
  const _$AppResultFailureImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'AppResult<$T>.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppResultFailureImpl<T> &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppResultFailureImplCopyWith<T, _$AppResultFailureImpl<T>> get copyWith =>
      __$$AppResultFailureImplCopyWithImpl<T, _$AppResultFailureImpl<T>>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this.failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppResultSuccess<T> value) success,
    required TResult Function(AppResultFailure<T> value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppResultSuccess<T> value)? success,
    TResult? Function(AppResultFailure<T> value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppResultSuccess<T> value)? success,
    TResult Function(AppResultFailure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class AppResultFailure<T> implements AppResult<T> {
  const factory AppResultFailure(final AppFailure failure) =
      _$AppResultFailureImpl<T>;

  AppFailure get failure;

  /// Create a copy of AppResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppResultFailureImplCopyWith<T, _$AppResultFailureImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
