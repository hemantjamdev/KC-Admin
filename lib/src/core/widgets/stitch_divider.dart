import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom painter for authentic tailor sewing thread line with --===-- (thin-thick-thin) thickness profile.
class StitchLinePainter extends CustomPainter {
  StitchLinePainter({
    required this.color,
    this.minThickness = 1.0,
    this.maxThickness = 2.6,
    this.dashWidth = 8.0,
    this.dashGap = 4.5,
  });

  final Color color;
  final double minThickness;
  final double maxThickness;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height / 2;
    double x = 0.0;

    while (x < size.width) {
      final double endX = (x + dashWidth).clamp(0.0, size.width);
      final double currentDashLen = endX - x;

      if (currentDashLen > 0) {
        const int steps = 6;
        for (int i = 0; i < steps; i++) {
          final double f1 = i / steps;
          final double f2 = (i + 1) / steps;
          final double x1 = x + currentDashLen * f1;
          final double x2 = x + currentDashLen * f2;
          final double fMid = (f1 + f2) / 2;

          // --===-- Sine envelope thickness profile
          final double w =
              minThickness +
              (maxThickness - minThickness) * math.sin(fMid * math.pi);

          final paint = Paint()
            ..color = color
            ..strokeWidth = w
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

          canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
        }
      }

      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant StitchLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.minThickness != minThickness ||
        oldDelegate.maxThickness != maxThickness ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

/// Editorial dashed divider with authentic tailor stitch motif --===-- (thin-thick-thin) dashes.
class StitchDivider extends StatelessWidget {
  const StitchDivider({
    super.key,
    this.icon,
    this.color,
    this.minThickness = 1.0,
    this.maxThickness = 2.6,
    this.dashWidth = 8.0,
    this.dashGap = 4.5,
    this.margin,
  });

  final IconData? icon;
  final Color? color;
  final double minThickness;
  final double maxThickness;
  final double dashWidth;
  final double dashGap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final threadColor = color ?? AppColors.primary.withValues(alpha: 0.38);

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 6,
              child: CustomPaint(
                painter: StitchLinePainter(
                  color: threadColor,
                  minThickness: minThickness,
                  maxThickness: maxThickness,
                  dashWidth: dashWidth,
                  dashGap: dashGap,
                ),
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 10),
            Icon(icon, size: 14, color: threadColor),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 6,
                child: CustomPaint(
                  painter: StitchLinePainter(
                    color: threadColor,
                    minThickness: minThickness,
                    maxThickness: maxThickness,
                    dashWidth: dashWidth,
                    dashGap: dashGap,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tailor-Stitch Custom Painter — paints a garment topstitch border with --===-- (thin-thick-thin) thread dashes:
/// 1. Optional outer fabric seam edge.
/// 2. Inset topstitch thread line where each stitch tapers smoothly from thin ends to a thick middle.
class DashedStitchBorderPainter extends CustomPainter {
  DashedStitchBorderPainter({
    required this.color,
    this.minThickness = 1.0,
    double? maxThickness,
    double? strokeWidth,
    this.dashWidth = 8.0,
    this.dashGap = 4.5,
    this.borderRadius = 16.0,
    this.inset = 4.5,
    this.drawOuterEdge = true,
  }) : maxThickness = maxThickness ?? strokeWidth ?? 2.6;

  final Color color;
  final double minThickness;
  final double maxThickness;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;
  final double inset;
  final bool drawOuterEdge;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw outer fabric seam edge (soft border)
    if (drawOuterEdge) {
      final outerEdgePaint = Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(outerRRect, outerEdgePaint);
    }

    // 2. Draw Inset Tailor Topstitch Line with --===-- (thin-thick-thin) stroke profile
    final double insetRadius = (borderRadius - inset).clamp(4.0, borderRadius);
    final RRect insetRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        (size.width - inset * 2).clamp(0.0, size.width),
        (size.height - inset * 2).clamp(0.0, size.height),
      ),
      Radius.circular(insetRadius),
    );

    final Path insetPath = Path()..addRRect(insetRRect);

    for (final PathMetric metric in insetPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;

        if (len > 0) {
          const int steps = 6;
          for (int i = 0; i < steps; i++) {
            final double f1 = i / steps;
            final double f2 = (i + 1) / steps;
            final double d1 = distance + len * f1;
            final double d2 = distance + len * f2;
            final double fMid = (f1 + f2) / 2;

            final Path subSegment = metric.extractPath(d1, d2);
            final double w =
                minThickness +
                (maxThickness - minThickness) * math.sin(fMid * math.pi);

            final paint = Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = w
              ..strokeCap = StrokeCap.round;

            canvas.drawPath(subSegment, paint);
          }
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedStitchBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.minThickness != minThickness ||
        oldDelegate.maxThickness != maxThickness ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.inset != inset ||
        oldDelegate.drawOuterEdge != drawOuterEdge;
  }
}

/// Reusable container with an authentic garment tailor-stitching border featuring --===-- thread dashes.
class DashedStitchContainer extends StatelessWidget {
  const DashedStitchContainer({
    super.key,
    required this.child,
    required this.borderColor,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.minThickness = 1.0,
    double? maxThickness,
    double? strokeWidth,
    this.dashWidth = 8.0,
    this.dashGap = 4.5,
    this.inset = 4.5,
    this.drawOuterEdge = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  }) : maxThickness = maxThickness ?? strokeWidth ?? 2.6;

  final Widget child;
  final Color borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double minThickness;
  final double maxThickness;
  final double dashWidth;
  final double dashGap;
  final double inset;
  final bool drawOuterEdge;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedStitchBorderPainter(
        color: borderColor,
        minThickness: minThickness,
        maxThickness: maxThickness,
        dashWidth: dashWidth,
        dashGap: dashGap,
        borderRadius: borderRadius,
        inset: inset,
        drawOuterEdge: drawOuterEdge,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
