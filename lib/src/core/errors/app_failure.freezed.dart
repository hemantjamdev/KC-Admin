// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppFailure {
  String? get message => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppFailureCopyWith<AppFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppFailureCopyWith<$Res> {
  factory $AppFailureCopyWith(
    AppFailure value,
    $Res Function(AppFailure) then,
  ) = _$AppFailureCopyWithImpl<$Res, AppFailure>;
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class _$AppFailureCopyWithImpl<$Res, $Val extends AppFailure>
    implements $AppFailureCopyWith<$Res> {
  _$AppFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            error: freezed == error ? _value.error : error,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppFailureNetworkImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureNetworkImplCopyWith(
    _$AppFailureNetworkImpl value,
    $Res Function(_$AppFailureNetworkImpl) then,
  ) = __$$AppFailureNetworkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureNetworkImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureNetworkImpl>
    implements _$$AppFailureNetworkImplCopyWith<$Res> {
  __$$AppFailureNetworkImplCopyWithImpl(
    _$AppFailureNetworkImpl _value,
    $Res Function(_$AppFailureNetworkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureNetworkImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureNetworkImpl implements _AppFailureNetwork {
  const _$AppFailureNetworkImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.network(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureNetworkImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureNetworkImplCopyWith<_$AppFailureNetworkImpl> get copyWith =>
      __$$AppFailureNetworkImplCopyWithImpl<_$AppFailureNetworkImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return network(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return network?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class _AppFailureNetwork implements AppFailure {
  const factory _AppFailureNetwork({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureNetworkImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureNetworkImplCopyWith<_$AppFailureNetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureTimeoutImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureTimeoutImplCopyWith(
    _$AppFailureTimeoutImpl value,
    $Res Function(_$AppFailureTimeoutImpl) then,
  ) = __$$AppFailureTimeoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureTimeoutImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureTimeoutImpl>
    implements _$$AppFailureTimeoutImplCopyWith<$Res> {
  __$$AppFailureTimeoutImplCopyWithImpl(
    _$AppFailureTimeoutImpl _value,
    $Res Function(_$AppFailureTimeoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureTimeoutImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureTimeoutImpl implements _AppFailureTimeout {
  const _$AppFailureTimeoutImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.timeout(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureTimeoutImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureTimeoutImplCopyWith<_$AppFailureTimeoutImpl> get copyWith =>
      __$$AppFailureTimeoutImplCopyWithImpl<_$AppFailureTimeoutImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return timeout(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return timeout?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return timeout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return timeout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(this);
    }
    return orElse();
  }
}

abstract class _AppFailureTimeout implements AppFailure {
  const factory _AppFailureTimeout({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureTimeoutImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureTimeoutImplCopyWith<_$AppFailureTimeoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureAuthenticationImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureAuthenticationImplCopyWith(
    _$AppFailureAuthenticationImpl value,
    $Res Function(_$AppFailureAuthenticationImpl) then,
  ) = __$$AppFailureAuthenticationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureAuthenticationImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureAuthenticationImpl>
    implements _$$AppFailureAuthenticationImplCopyWith<$Res> {
  __$$AppFailureAuthenticationImplCopyWithImpl(
    _$AppFailureAuthenticationImpl _value,
    $Res Function(_$AppFailureAuthenticationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureAuthenticationImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureAuthenticationImpl implements _AppFailureAuthentication {
  const _$AppFailureAuthenticationImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.authentication(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureAuthenticationImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureAuthenticationImplCopyWith<_$AppFailureAuthenticationImpl>
  get copyWith =>
      __$$AppFailureAuthenticationImplCopyWithImpl<
        _$AppFailureAuthenticationImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return authentication(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return authentication?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return authentication(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return authentication?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(this);
    }
    return orElse();
  }
}

abstract class _AppFailureAuthentication implements AppFailure {
  const factory _AppFailureAuthentication({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureAuthenticationImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureAuthenticationImplCopyWith<_$AppFailureAuthenticationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailurePermissionImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailurePermissionImplCopyWith(
    _$AppFailurePermissionImpl value,
    $Res Function(_$AppFailurePermissionImpl) then,
  ) = __$$AppFailurePermissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailurePermissionImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailurePermissionImpl>
    implements _$$AppFailurePermissionImplCopyWith<$Res> {
  __$$AppFailurePermissionImplCopyWithImpl(
    _$AppFailurePermissionImpl _value,
    $Res Function(_$AppFailurePermissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailurePermissionImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailurePermissionImpl implements _AppFailurePermission {
  const _$AppFailurePermissionImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.permission(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailurePermissionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailurePermissionImplCopyWith<_$AppFailurePermissionImpl>
  get copyWith =>
      __$$AppFailurePermissionImplCopyWithImpl<_$AppFailurePermissionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return permission(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return permission?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class _AppFailurePermission implements AppFailure {
  const factory _AppFailurePermission({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailurePermissionImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailurePermissionImplCopyWith<_$AppFailurePermissionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureValidationImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureValidationImplCopyWith(
    _$AppFailureValidationImpl value,
    $Res Function(_$AppFailureValidationImpl) then,
  ) = __$$AppFailureValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureValidationImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureValidationImpl>
    implements _$$AppFailureValidationImplCopyWith<$Res> {
  __$$AppFailureValidationImplCopyWithImpl(
    _$AppFailureValidationImpl _value,
    $Res Function(_$AppFailureValidationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureValidationImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureValidationImpl implements _AppFailureValidation {
  const _$AppFailureValidationImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.validation(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureValidationImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureValidationImplCopyWith<_$AppFailureValidationImpl>
  get copyWith =>
      __$$AppFailureValidationImplCopyWithImpl<_$AppFailureValidationImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return validation(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return validation?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class _AppFailureValidation implements AppFailure {
  const factory _AppFailureValidation({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureValidationImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureValidationImplCopyWith<_$AppFailureValidationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureNotFoundImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureNotFoundImplCopyWith(
    _$AppFailureNotFoundImpl value,
    $Res Function(_$AppFailureNotFoundImpl) then,
  ) = __$$AppFailureNotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureNotFoundImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureNotFoundImpl>
    implements _$$AppFailureNotFoundImplCopyWith<$Res> {
  __$$AppFailureNotFoundImplCopyWithImpl(
    _$AppFailureNotFoundImpl _value,
    $Res Function(_$AppFailureNotFoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureNotFoundImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureNotFoundImpl implements _AppFailureNotFound {
  const _$AppFailureNotFoundImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.notFound(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureNotFoundImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureNotFoundImplCopyWith<_$AppFailureNotFoundImpl> get copyWith =>
      __$$AppFailureNotFoundImplCopyWithImpl<_$AppFailureNotFoundImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return notFound(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return notFound?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class _AppFailureNotFound implements AppFailure {
  const factory _AppFailureNotFound({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureNotFoundImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureNotFoundImplCopyWith<_$AppFailureNotFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureServerImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureServerImplCopyWith(
    _$AppFailureServerImpl value,
    $Res Function(_$AppFailureServerImpl) then,
  ) = __$$AppFailureServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureServerImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureServerImpl>
    implements _$$AppFailureServerImplCopyWith<$Res> {
  __$$AppFailureServerImplCopyWithImpl(
    _$AppFailureServerImpl _value,
    $Res Function(_$AppFailureServerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureServerImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureServerImpl implements _AppFailureServer {
  const _$AppFailureServerImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.server(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureServerImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureServerImplCopyWith<_$AppFailureServerImpl> get copyWith =>
      __$$AppFailureServerImplCopyWithImpl<_$AppFailureServerImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return server(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return server?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class _AppFailureServer implements AppFailure {
  const factory _AppFailureServer({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureServerImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureServerImplCopyWith<_$AppFailureServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureStorageImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureStorageImplCopyWith(
    _$AppFailureStorageImpl value,
    $Res Function(_$AppFailureStorageImpl) then,
  ) = __$$AppFailureStorageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureStorageImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureStorageImpl>
    implements _$$AppFailureStorageImplCopyWith<$Res> {
  __$$AppFailureStorageImplCopyWithImpl(
    _$AppFailureStorageImpl _value,
    $Res Function(_$AppFailureStorageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureStorageImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureStorageImpl implements _AppFailureStorage {
  const _$AppFailureStorageImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.storage(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureStorageImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureStorageImplCopyWith<_$AppFailureStorageImpl> get copyWith =>
      __$$AppFailureStorageImplCopyWithImpl<_$AppFailureStorageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return storage(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return storage?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class _AppFailureStorage implements AppFailure {
  const factory _AppFailureStorage({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureStorageImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureStorageImplCopyWith<_$AppFailureStorageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppFailureUnknownImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$AppFailureUnknownImplCopyWith(
    _$AppFailureUnknownImpl value,
    $Res Function(_$AppFailureUnknownImpl) then,
  ) = __$$AppFailureUnknownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? code, Object? error});
}

/// @nodoc
class __$$AppFailureUnknownImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$AppFailureUnknownImpl>
    implements _$$AppFailureUnknownImplCopyWith<$Res> {
  __$$AppFailureUnknownImplCopyWithImpl(
    _$AppFailureUnknownImpl _value,
    $Res Function(_$AppFailureUnknownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AppFailureUnknownImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$AppFailureUnknownImpl implements _AppFailureUnknown {
  const _$AppFailureUnknownImpl({this.message, this.code, this.error});

  @override
  final String? message;
  @override
  final String? code;
  @override
  final Object? error;

  @override
  String toString() {
    return 'AppFailure.unknown(message: $message, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppFailureUnknownImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppFailureUnknownImplCopyWith<_$AppFailureUnknownImpl> get copyWith =>
      __$$AppFailureUnknownImplCopyWithImpl<_$AppFailureUnknownImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message, String? code, Object? error)
    network,
    required TResult Function(String? message, String? code, Object? error)
    timeout,
    required TResult Function(String? message, String? code, Object? error)
    authentication,
    required TResult Function(String? message, String? code, Object? error)
    permission,
    required TResult Function(String? message, String? code, Object? error)
    validation,
    required TResult Function(String? message, String? code, Object? error)
    notFound,
    required TResult Function(String? message, String? code, Object? error)
    server,
    required TResult Function(String? message, String? code, Object? error)
    storage,
    required TResult Function(String? message, String? code, Object? error)
    unknown,
  }) {
    return unknown(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, String? code, Object? error)? network,
    TResult? Function(String? message, String? code, Object? error)? timeout,
    TResult? Function(String? message, String? code, Object? error)?
    authentication,
    TResult? Function(String? message, String? code, Object? error)? permission,
    TResult? Function(String? message, String? code, Object? error)? validation,
    TResult? Function(String? message, String? code, Object? error)? notFound,
    TResult? Function(String? message, String? code, Object? error)? server,
    TResult? Function(String? message, String? code, Object? error)? storage,
    TResult? Function(String? message, String? code, Object? error)? unknown,
  }) {
    return unknown?.call(message, code, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, String? code, Object? error)? network,
    TResult Function(String? message, String? code, Object? error)? timeout,
    TResult Function(String? message, String? code, Object? error)?
    authentication,
    TResult Function(String? message, String? code, Object? error)? permission,
    TResult Function(String? message, String? code, Object? error)? validation,
    TResult Function(String? message, String? code, Object? error)? notFound,
    TResult Function(String? message, String? code, Object? error)? server,
    TResult Function(String? message, String? code, Object? error)? storage,
    TResult Function(String? message, String? code, Object? error)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, code, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AppFailureNetwork value) network,
    required TResult Function(_AppFailureTimeout value) timeout,
    required TResult Function(_AppFailureAuthentication value) authentication,
    required TResult Function(_AppFailurePermission value) permission,
    required TResult Function(_AppFailureValidation value) validation,
    required TResult Function(_AppFailureNotFound value) notFound,
    required TResult Function(_AppFailureServer value) server,
    required TResult Function(_AppFailureStorage value) storage,
    required TResult Function(_AppFailureUnknown value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AppFailureNetwork value)? network,
    TResult? Function(_AppFailureTimeout value)? timeout,
    TResult? Function(_AppFailureAuthentication value)? authentication,
    TResult? Function(_AppFailurePermission value)? permission,
    TResult? Function(_AppFailureValidation value)? validation,
    TResult? Function(_AppFailureNotFound value)? notFound,
    TResult? Function(_AppFailureServer value)? server,
    TResult? Function(_AppFailureStorage value)? storage,
    TResult? Function(_AppFailureUnknown value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AppFailureNetwork value)? network,
    TResult Function(_AppFailureTimeout value)? timeout,
    TResult Function(_AppFailureAuthentication value)? authentication,
    TResult Function(_AppFailurePermission value)? permission,
    TResult Function(_AppFailureValidation value)? validation,
    TResult Function(_AppFailureNotFound value)? notFound,
    TResult Function(_AppFailureServer value)? server,
    TResult Function(_AppFailureStorage value)? storage,
    TResult Function(_AppFailureUnknown value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class _AppFailureUnknown implements AppFailure {
  const factory _AppFailureUnknown({
    final String? message,
    final String? code,
    final Object? error,
  }) = _$AppFailureUnknownImpl;

  @override
  String? get message;
  @override
  String? get code;
  @override
  Object? get error;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppFailureUnknownImplCopyWith<_$AppFailureUnknownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
