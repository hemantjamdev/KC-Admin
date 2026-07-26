import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_environment.dart';

part 'environment_config.freezed.dart';

@freezed
class EnvironmentConfig with _$EnvironmentConfig {
  const factory EnvironmentConfig({
    required AppEnvironment environment,
    required String apiBaseUrl,
    required bool enableLogs,
    required bool enableAnalytics,
    required String environmentName,
  }) = _EnvironmentConfig;

  factory EnvironmentConfig.development() {
    return const EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'https://admin-api.dev.kapadacreation.com',
      enableLogs: true,
      enableAnalytics: false,
      environmentName: 'Development',
    );
  }

  factory EnvironmentConfig.staging() {
    return const EnvironmentConfig(
      environment: AppEnvironment.staging,
      apiBaseUrl: 'https://admin-api.staging.kapadacreation.com',
      enableLogs: true,
      enableAnalytics: true,
      environmentName: 'Staging',
    );
  }

  factory EnvironmentConfig.production() {
    return const EnvironmentConfig(
      environment: AppEnvironment.production,
      apiBaseUrl: 'https://admin-api.kapadacreation.com',
      enableLogs: false,
      enableAnalytics: true,
      environmentName: 'Production',
    );
  }
}
