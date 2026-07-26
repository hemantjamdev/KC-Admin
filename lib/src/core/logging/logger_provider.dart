import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import 'app_logger.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  final env = ref.watch(environmentConfigProvider);
  return AppLogger(enabled: env.enableLogs);
});
