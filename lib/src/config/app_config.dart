import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'environment/environment.dart';

class AppConfig {
  AppConfig({required this.environmentConfig});

  final EnvironmentConfig environmentConfig;

  static EnvironmentConfig _currentConfig = EnvironmentConfig.development();

  static EnvironmentConfig get current => _currentConfig;

  static void setEnvironment(EnvironmentConfig config) {
    _currentConfig = config;
  }
}

final environmentConfigProvider = Provider<EnvironmentConfig>((ref) {
  return AppConfig.current;
});
