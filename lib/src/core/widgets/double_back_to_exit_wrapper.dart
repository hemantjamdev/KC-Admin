import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_routes.dart';
import 'app_toast.dart';

/// Wraps root/shell screens to prevent immediate exit on back press.
/// - Debounces rapid OS back gesture callbacks (< 600ms).
/// - Switches non-home shell tabs to Home tab first.
/// - Shows warning toast on 1st back press on Home tab.
/// - Exits app on 2nd intentional back tap within 2.5s window.
class DoubleBackToExitWrapper extends StatefulWidget {
  const DoubleBackToExitWrapper({
    super.key,
    required this.child,
    this.currentTabIndex,
  });

  final Widget child;
  final int? currentTabIndex;

  @override
  State<DoubleBackToExitWrapper> createState() =>
      _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastBackPressTime;

  @override
  void didUpdateWidget(covariant DoubleBackToExitWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTabIndex != widget.currentTabIndex) {
      _lastBackPressTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If on a non-home shell tab (e.g. Profile, Products, Insights), navigate to Home tab
        if (widget.currentTabIndex != null && widget.currentTabIndex! > 0) {
          _lastBackPressTime = null;
          context.go(AppRoutes.adminHome);
          return;
        }

        final now = DateTime.now();

        // Check if a previous back tap exists
        if (_lastBackPressTime != null) {
          final timeDiff = now.difference(_lastBackPressTime!).inMilliseconds;

          // Ignore rapid duplicate OS gesture callbacks (< 350ms)
          if (timeDiff < 350) {
            return;
          }

          // Real 2nd tap within 2000ms (2 seconds): exit the app!
          if (timeDiff <= 2000) {
            await SystemNavigator.pop();
            return;
          }
        }

        // 1st tap (or > 2000ms delay since previous tap): record timestamp & show warning toast
        _lastBackPressTime = now;

        if (!mounted) return;
        AppToast.show(
          context,
          'Press again to exit the app',
          icon: Icons.warning_amber_rounded,
          type: ToastType.warning,
        );
      },
      child: widget.child,
    );
  }
}
