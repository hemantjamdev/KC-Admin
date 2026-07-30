import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload_model.freezed.dart';
part 'notification_payload_model.g.dart';

@freezed
class NotificationPayloadModel with _$NotificationPayloadModel {
  const factory NotificationPayloadModel({
    required String notificationId,
    required String type,
    required String route,
    String? targetId,
    @Default({}) Map<String, dynamic> rawData,
  }) = _NotificationPayloadModel;

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadModelFromJson(json);
}
