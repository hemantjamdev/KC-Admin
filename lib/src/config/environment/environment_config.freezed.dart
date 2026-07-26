// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EnvironmentConfig {
  AppEnvironment get environment => throw _privateConstructorUsedError;
  String get apiBaseUrl => throw _privateConstructorUsedError;
  bool get enableLogs => throw _privateConstructorUsedError;
  bool get enableAnalytics => throw _privateConstructorUsedError;
  String get environmentName => throw _privateConstructorUsedError;

  /// Create a copy of EnvironmentConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnvironmentConfigCopyWith<EnvironmentConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnvironmentConfigCopyWith<$Res> {
  factory $EnvironmentConfigCopyWith(
    EnvironmentConfig value,
    $Res Function(EnvironmentConfig) then,
  ) = _$EnvironmentConfigCopyWithImpl<$Res, EnvironmentConfig>;
  @useResult
  $Res call({
    AppEnvironment environment,
    String apiBaseUrl,
    bool enableLogs,
    bool enableAnalytics,
    String environmentName,
  });
}

/// @nodoc
class _$EnvironmentConfigCopyWithImpl<$Res, $Val extends EnvironmentConfig>
    implements $EnvironmentConfigCopyWith<$Res> {
  _$EnvironmentConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnvironmentConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? environment = null,
    Object? apiBaseUrl = null,
    Object? enableLogs = null,
    Object? enableAnalytics = null,
    Object? environmentName = null,
  }) {
    return _then(
      _value.copyWith(
            environment: null == environment
                ? _value.environment
                : environment // ignore: cast_nullable_to_non_nullable
                      as AppEnvironment,
            apiBaseUrl: null == apiBaseUrl
                ? _value.apiBaseUrl
                : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            enableLogs: null == enableLogs
                ? _value.enableLogs
                : enableLogs // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableAnalytics: null == enableAnalytics
                ? _value.enableAnalytics
                : enableAnalytics // ignore: cast_nullable_to_non_nullable
                      as bool,
            environmentName: null == environmentName
                ? _value.environmentName
                : environmentName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnvironmentConfigImplCopyWith<$Res>
    implements $EnvironmentConfigCopyWith<$Res> {
  factory _$$EnvironmentConfigImplCopyWith(
    _$EnvironmentConfigImpl value,
    $Res Function(_$EnvironmentConfigImpl) then,
  ) = __$$EnvironmentConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AppEnvironment environment,
    String apiBaseUrl,
    bool enableLogs,
    bool enableAnalytics,
    String environmentName,
  });
}

/// @nodoc
class __$$EnvironmentConfigImplCopyWithImpl<$Res>
    extends _$EnvironmentConfigCopyWithImpl<$Res, _$EnvironmentConfigImpl>
    implements _$$EnvironmentConfigImplCopyWith<$Res> {
  __$$EnvironmentConfigImplCopyWithImpl(
    _$EnvironmentConfigImpl _value,
    $Res Function(_$EnvironmentConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnvironmentConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? environment = null,
    Object? apiBaseUrl = null,
    Object? enableLogs = null,
    Object? enableAnalytics = null,
    Object? environmentName = null,
  }) {
    return _then(
      _$EnvironmentConfigImpl(
        environment: null == environment
            ? _value.environment
            : environment // ignore: cast_nullable_to_non_nullable
                  as AppEnvironment,
        apiBaseUrl: null == apiBaseUrl
            ? _value.apiBaseUrl
            : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        enableLogs: null == enableLogs
            ? _value.enableLogs
            : enableLogs // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableAnalytics: null == enableAnalytics
            ? _value.enableAnalytics
            : enableAnalytics // ignore: cast_nullable_to_non_nullable
                  as bool,
        environmentName: null == environmentName
            ? _value.environmentName
            : environmentName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$EnvironmentConfigImpl implements _EnvironmentConfig {
  const _$EnvironmentConfigImpl({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogs,
    required this.enableAnalytics,
    required this.environmentName,
  });

  @override
  final AppEnvironment environment;
  @override
  final String apiBaseUrl;
  @override
  final bool enableLogs;
  @override
  final bool enableAnalytics;
  @override
  final String environmentName;

  @override
  String toString() {
    return 'EnvironmentConfig(environment: $environment, apiBaseUrl: $apiBaseUrl, enableLogs: $enableLogs, enableAnalytics: $enableAnalytics, environmentName: $environmentName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnvironmentConfigImpl &&
            (identical(other.environment, environment) ||
                other.environment == environment) &&
            (identical(other.apiBaseUrl, apiBaseUrl) ||
                other.apiBaseUrl == apiBaseUrl) &&
            (identical(other.enableLogs, enableLogs) ||
                other.enableLogs == enableLogs) &&
            (identical(other.enableAnalytics, enableAnalytics) ||
                other.enableAnalytics == enableAnalytics) &&
            (identical(other.environmentName, environmentName) ||
                other.environmentName == environmentName));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    environment,
    apiBaseUrl,
    enableLogs,
    enableAnalytics,
    environmentName,
  );

  /// Create a copy of EnvironmentConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnvironmentConfigImplCopyWith<_$EnvironmentConfigImpl> get copyWith =>
      __$$EnvironmentConfigImplCopyWithImpl<_$EnvironmentConfigImpl>(
        this,
        _$identity,
      );
}

abstract class _EnvironmentConfig implements EnvironmentConfig {
  const factory _EnvironmentConfig({
    required final AppEnvironment environment,
    required final String apiBaseUrl,
    required final bool enableLogs,
    required final bool enableAnalytics,
    required final String environmentName,
  }) = _$EnvironmentConfigImpl;

  @override
  AppEnvironment get environment;
  @override
  String get apiBaseUrl;
  @override
  bool get enableLogs;
  @override
  bool get enableAnalytics;
  @override
  String get environmentName;

  /// Create a copy of EnvironmentConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnvironmentConfigImplCopyWith<_$EnvironmentConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
