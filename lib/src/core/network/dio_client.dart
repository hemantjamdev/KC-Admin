import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'interceptors/app_log_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'network_config.dart';

class DioClient {
  DioClient({
    required NetworkConfig config,
    required AppLogger logger,
    bool enableLogging = true,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: config.baseUrl,
           connectTimeout: config.connectTimeout,
           receiveTimeout: config.receiveTimeout,
           sendTimeout: config.sendTimeout,
           headers: const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.add(AuthInterceptor());
    if (enableLogging) {
      _dio.interceptors.add(AppLogInterceptor(logger));
    }
  }

  final Dio _dio;

  Dio get instance => _dio;
}
