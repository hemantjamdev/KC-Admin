import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { success, info, warning, error }

/// Custom Toast implementation for KC-Admin.
/// Features:
/// - White background
/// - Green border
/// - Green text & icon
/// - Bounce-in animation from bottom
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  /// Shows a custom animated toast at the bottom of the screen.
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    // Remove any active toast before showing a new one
    dismissCurrent();

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        type: type,
        icon: icon,
        duration: duration,
        onDismissed: () {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  /// Immediately dismisses the active toast if present.
  static void dismissCurrent() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.icon,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;
  final IconData? icon;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 300),
    );

    // Bounce-in from bottom curve (easeOutBack gives a crisp bounce-in effect)
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1.8), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInBack,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Auto-dismiss timer
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    if (widget.icon != null) return widget.icon!;
    return switch (widget.type) {
      ToastType.success => Icons.check_circle_rounded,
      ToastType.info => Icons.info_rounded,
      ToastType.warning => Icons.warning_amber_rounded,
      ToastType.error => Icons.error_outline_rounded,
    };
  }

  Color _getBorderColor() {
    return switch (widget.type) {
      ToastType.success => AppColors.success,
      ToastType.warning => AppColors.warning,
      ToastType.error => AppColors.error,
      ToastType.info => AppColors.brandGreen700,
    };
  }

  Color _getIconColor() {
    return switch (widget.type) {
      ToastType.success => AppColors.success,
      ToastType.warning => AppColors.warning,
      ToastType.error => AppColors.error,
      ToastType.info => AppColors.brandGreen700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;

    final borderColor = _getBorderColor();
    final iconColor = _getIconColor();
    const textColor = AppColors.brandGreen900;

    return Positioned(
      bottom: bottomInset + bottomPadding + 24,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: _offsetAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_getIcon(), color: iconColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
