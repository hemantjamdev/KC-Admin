// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPayloadModelImpl _$$NotificationPayloadModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPayloadModelImpl(
  notificationId: json['notificationId'] as String,
  type: json['type'] as String,
  route: json['route'] as String,
  targetId: json['targetId'] as String?,
  rawData: json['rawData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$NotificationPayloadModelImplToJson(
  _$NotificationPayloadModelImpl instance,
) => <String, dynamic>{
  'notificationId': instance.notificationId,
  'type': instance.type,
  'route': instance.route,
  'targetId': instance.targetId,
  'rawData': instance.rawData,
};
