import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';

class AppLogInterceptor extends Interceptor {
  AppLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('HTTP Request: [${options.method}] ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      'HTTP Response: [${response.statusCode}] ${response.requestOptions.uri}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      'HTTP Error: [${err.response?.statusCode}] ${err.requestOptions.uri}',
      err,
      err.stackTrace,
    );
    super.onError(err, handler);
  }
}
