import 'dart:ui';
import 'package:flutter/widgets.dart';

class BootstrapErrorHandler {
  const BootstrapErrorHandler._();

  static void setupErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      return true;
    };
  }
}
