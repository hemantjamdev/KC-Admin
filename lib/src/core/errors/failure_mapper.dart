import 'dart:async';
import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'app_failure.dart';

class FailureMapper {
  const FailureMapper._();

  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppFailure.timeout(
            message: 'Connection timed out. Please try again.',
            error: error,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return AppFailure.authentication(
              message: 'Authentication failed.',
              code: '401',
              error: error,
            );
          } else if (statusCode == 403) {
            return AppFailure.permission(
              message: 'Access denied.',
              code: '403',
              error: error,
            );
          } else if (statusCode == 404) {
            return AppFailure.notFound(
              message: 'Requested resource not found.',
              code: '404',
              error: error,
            );
          } else if (statusCode != null && statusCode >= 500) {
            return AppFailure.server(
              message: 'Server error occurred. Please try again later.',
              code: '$statusCode',
              error: error,
            );
          }
          return AppFailure.unknown(
            message: 'An unexpected HTTP error occurred.',
            code: statusCode != null ? '$statusCode' : null,
            error: error,
          );
        case DioExceptionType.cancel:
          return AppFailure.unknown(
            message: 'Request was cancelled.',
            error: error,
          );
        case DioExceptionType.connectionError:
          return AppFailure.network(
            message: 'Network connection failure. Please check your internet.',
            error: error,
          );
        case DioExceptionType.unknown:
        default:
          return AppFailure.unknown(
            message: 'An unexpected network error occurred.',
            error: error,
          );
      }
    }

    if (error is TimeoutException) {
      return AppFailure.timeout(message: 'Operation timed out.', error: error);
    }

    if (error is AppException) {
      return AppFailure.unknown(
        message: error.message,
        code: error.code,
        error: error.originalError,
      );
    }

    return AppFailure.unknown(message: error.toString(), error: error);
  }
}
