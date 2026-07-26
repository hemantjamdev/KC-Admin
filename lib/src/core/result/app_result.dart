import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/app_failure.dart';

part 'app_result.freezed.dart';

@freezed
sealed class AppResult<T> with _$AppResult<T> {
  const factory AppResult.success(T data) = AppResultSuccess<T>;
  const factory AppResult.failure(AppFailure failure) = AppResultFailure<T>;
}

extension AppResultX<T> on AppResult<T> {
  bool get isSuccess => this is AppResultSuccess<T>;
  bool get isFailure => this is AppResultFailure<T>;

  T? get dataOrNull => when(success: (data) => data, failure: (_) => null);

  AppFailure? get failureOrNull =>
      when(success: (_) => null, failure: (failure) => failure);
}
