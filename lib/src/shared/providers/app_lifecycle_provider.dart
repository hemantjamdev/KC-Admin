import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider = Provider<AppLifecycleState>((ref) {
  final observer = _AppLifecycleObserver(ref);
  final binding = WidgetsBinding.instance;
  binding.addObserver(observer);
  ref.onDispose(() => binding.removeObserver(observer));
  return observer.state;
});

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this.ref);

  final Ref ref;
  AppLifecycleState state = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState nextState) {
    state = nextState;
  }
}
