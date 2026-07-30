import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/app_failure.dart';

part 'notification_messaging_state.freezed.dart';

@freezed
sealed class NotificationMessagingState with _$NotificationMessagingState {
  const factory NotificationMessagingState.idle() = NotificationMessagingIdle;

  const factory NotificationMessagingState.initializing() =
      NotificationMessagingInitializing;

  const factory NotificationMessagingState.ready({
    required bool tokenRegistered,
    required String token,
  }) = NotificationMessagingReady;

  const factory NotificationMessagingState.permissionDenied() =
      NotificationMessagingPermissionDenied;

  const factory NotificationMessagingState.tokenRegistrationFailed(
    AppFailure failure,
  ) = NotificationMessagingTokenRegistrationFailed;

  const factory NotificationMessagingState.failure(AppFailure failure) =
      NotificationMessagingFailure;
}
