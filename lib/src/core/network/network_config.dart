import '../constants/app_constants.dart';

class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(
      milliseconds: AppConstants.connectTimeoutMs,
    ),
    this.receiveTimeout = const Duration(
      milliseconds: AppConstants.receiveTimeoutMs,
    ),
    this.sendTimeout = const Duration(milliseconds: AppConstants.sendTimeoutMs),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
}
