import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/network_listener_wrapper.dart';
import 'app_routes.dart';
import 'app_theme.dart';

/// Root application widget for Kapada Creation Admin.
/// Uses ConsumerStatefulWidget to access the Riverpod container for router creation.
class KcAdminApp extends ConsumerStatefulWidget {
  const KcAdminApp({super.key});

  @override
  ConsumerState<KcAdminApp> createState() => _KcAdminAppState();
}

class _KcAdminAppState extends ConsumerState<KcAdminApp> {
  late final _router = createAppRouter(ProviderScope.containerOf(context));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kapada Creation Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: NetworkListenerWrapper(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
