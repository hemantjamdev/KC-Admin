import 'package:logger/logger.dart';

class AppLogger {
  AppLogger({required bool enabled})
    : _logger = Logger(
        filter: enabled ? ProductionFilter() : DevelopmentFilter(),
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: true,
          printEmojis: true,
        ),
      ),
      _enabled = enabled;

  final Logger _logger;
  final bool _enabled;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}
