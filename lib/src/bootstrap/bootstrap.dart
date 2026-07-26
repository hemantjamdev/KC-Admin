import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap_error_handler.dart';

Future<void> bootstrap(Widget Function() builder) async {
  BootstrapErrorHandler.setupErrorHandlers();

  runApp(ProviderScope(child: builder()));
}
