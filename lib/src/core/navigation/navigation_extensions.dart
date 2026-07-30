import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Extension methods for consistent navigation and safe back-stack pops.
extension NavigationContextX on BuildContext {
  /// Pops the current route if the navigator stack can be popped.
  /// Otherwise, navigates to [fallbackLocation] using [go].
  void popOrGo(String fallbackLocation) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackLocation);
    }
  }

  /// Pops the current route with a result if popping is possible.
  /// Otherwise, falls back to [fallbackLocation] if provided.
  void popOrGoWithResult<T>([T? result, String? fallbackLocation]) {
    if (canPop()) {
      pop(result);
    } else if (fallbackLocation != null) {
      go(fallbackLocation);
    }
  }
}
