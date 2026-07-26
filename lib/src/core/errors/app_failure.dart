import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureNetwork;

  const factory AppFailure.timeout({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureTimeout;

  const factory AppFailure.authentication({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureAuthentication;

  const factory AppFailure.permission({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailurePermission;

  const factory AppFailure.validation({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureValidation;

  const factory AppFailure.notFound({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureNotFound;

  const factory AppFailure.server({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureServer;

  const factory AppFailure.storage({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureStorage;

  const factory AppFailure.unknown({
    String? message,
    String? code,
    Object? error,
  }) = _AppFailureUnknown;
}
