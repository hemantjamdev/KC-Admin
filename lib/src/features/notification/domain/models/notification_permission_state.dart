import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/app_failure.dart';

part 'notification_permission_state.freezed.dart';

@freezed
sealed class NotificationPermissionState with _$NotificationPermissionState {
  const factory NotificationPermissionState.unknown() =
      NotificationPermissionUnknown;

  const factory NotificationPermissionState.notRequested() =
      NotificationPermissionNotRequested;

  const factory NotificationPermissionState.requesting() =
      NotificationPermissionRequesting;

  const factory NotificationPermissionState.granted() =
      NotificationPermissionGranted;

  const factory NotificationPermissionState.denied() =
      NotificationPermissionDenied;

  const factory NotificationPermissionState.permanentlyDenied() =
      NotificationPermissionPermanentlyDenied;

  const factory NotificationPermissionState.notRequired() =
      NotificationPermissionNotRequired;

  const factory NotificationPermissionState.failure(AppFailure failure) =
      NotificationPermissionFailure;
}
