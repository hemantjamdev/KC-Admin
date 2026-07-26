import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Placeholder for future authentication token header injection
    super.onRequest(options, handler);
  }
}
