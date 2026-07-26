import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../logging/logger_provider.dart';
import 'dio_client.dart';
import 'network_config.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final env = ref.watch(environmentConfigProvider);
  final logger = ref.watch(appLoggerProvider);

  final config = NetworkConfig(baseUrl: env.apiBaseUrl);

  return DioClient(
    config: config,
    logger: logger,
    enableLogging: env.enableLogs,
  );
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).instance;
});
