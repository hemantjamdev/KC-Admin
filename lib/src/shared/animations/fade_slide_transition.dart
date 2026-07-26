import 'package:flutter/material.dart';
import 'app_animations.dart';

class FadeSlideTransition extends StatelessWidget {
  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = AppAnimations.defaultDuration,
    this.curve = AppAnimations.defaultCurve,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
