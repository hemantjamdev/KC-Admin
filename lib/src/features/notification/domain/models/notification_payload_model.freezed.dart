// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_payload_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationPayloadModel _$NotificationPayloadModelFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationPayloadModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationPayloadModel {
  String get notificationId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;
  String? get targetId => throw _privateConstructorUsedError;
  Map<String, dynamic> get rawData => throw _privateConstructorUsedError;

  /// Serializes this NotificationPayloadModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPayloadModelCopyWith<NotificationPayloadModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPayloadModelCopyWith<$Res> {
  factory $NotificationPayloadModelCopyWith(
    NotificationPayloadModel value,
    $Res Function(NotificationPayloadModel) then,
  ) = _$NotificationPayloadModelCopyWithImpl<$Res, NotificationPayloadModel>;
  @useResult
  $Res call({
    String notificationId,
    String type,
    String route,
    String? targetId,
    Map<String, dynamic> rawData,
  });
}

/// @nodoc
class _$NotificationPayloadModelCopyWithImpl<
  $Res,
  $Val extends NotificationPayloadModel
>
    implements $NotificationPayloadModelCopyWith<$Res> {
  _$NotificationPayloadModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? type = null,
    Object? route = null,
    Object? targetId = freezed,
    Object? rawData = null,
  }) {
    return _then(
      _value.copyWith(
            notificationId: null == notificationId
                ? _value.notificationId
                : notificationId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String,
            targetId: freezed == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rawData: null == rawData
                ? _value.rawData
                : rawData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPayloadModelImplCopyWith<$Res>
    implements $NotificationPayloadModelCopyWith<$Res> {
  factory _$$NotificationPayloadModelImplCopyWith(
    _$NotificationPayloadModelImpl value,
    $Res Function(_$NotificationPayloadModelImpl) then,
  ) = __$$NotificationPayloadModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String notificationId,
    String type,
    String route,
    String? targetId,
    Map<String, dynamic> rawData,
  });
}

/// @nodoc
class __$$NotificationPayloadModelImplCopyWithImpl<$Res>
    extends
        _$NotificationPayloadModelCopyWithImpl<
          $Res,
          _$NotificationPayloadModelImpl
        >
    implements _$$NotificationPayloadModelImplCopyWith<$Res> {
  __$$NotificationPayloadModelImplCopyWithImpl(
    _$NotificationPayloadModelImpl _value,
    $Res Function(_$NotificationPayloadModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? type = null,
    Object? route = null,
    Object? targetId = freezed,
    Object? rawData = null,
  }) {
    return _then(
      _$NotificationPayloadModelImpl(
        notificationId: null == notificationId
            ? _value.notificationId
            : notificationId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: freezed == targetId
            ? _value.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rawData: null == rawData
            ? _value._rawData
            : rawData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPayloadModelImpl implements _NotificationPayloadModel {
  const _$NotificationPayloadModelImpl({
    required this.notificationId,
    required this.type,
    required this.route,
    this.targetId,
    final Map<String, dynamic> rawData = const {},
  }) : _rawData = rawData;

  factory _$NotificationPayloadModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPayloadModelImplFromJson(json);

  @override
  final String notificationId;
  @override
  final String type;
  @override
  final String route;
  @override
  final String? targetId;
  final Map<String, dynamic> _rawData;
  @override
  @JsonKey()
  Map<String, dynamic> get rawData {
    if (_rawData is EqualUnmodifiableMapView) return _rawData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawData);
  }

  @override
  String toString() {
    return 'NotificationPayloadModel(notificationId: $notificationId, type: $type, route: $route, targetId: $targetId, rawData: $rawData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPayloadModelImpl &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            const DeepCollectionEquality().equals(other._rawData, _rawData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    notificationId,
    type,
    route,
    targetId,
    const DeepCollectionEquality().hash(_rawData),
  );

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPayloadModelImplCopyWith<_$NotificationPayloadModelImpl>
  get copyWith =>
      __$$NotificationPayloadModelImplCopyWithImpl<
        _$NotificationPayloadModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPayloadModelImplToJson(this);
  }
}

abstract class _NotificationPayloadModel implements NotificationPayloadModel {
  const factory _NotificationPayloadModel({
    required final String notificationId,
    required final String type,
    required final String route,
    final String? targetId,
    final Map<String, dynamic> rawData,
  }) = _$NotificationPayloadModelImpl;

  factory _NotificationPayloadModel.fromJson(Map<String, dynamic> json) =
      _$NotificationPayloadModelImpl.fromJson;

  @override
  String get notificationId;
  @override
  String get type;
  @override
  String get route;
  @override
  String? get targetId;
  @override
  Map<String, dynamic> get rawData;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPayloadModelImplCopyWith<_$NotificationPayloadModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
