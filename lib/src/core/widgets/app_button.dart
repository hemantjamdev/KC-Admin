import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import 'app_loading_indicator.dart';

enum AppButtonVariant { primary, secondary, text }

/// Reusable premium button component for Kapada Creation apps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 52.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          AppLoadingIndicator(
            size: 20.0,
            color: variant == AppButtonVariant.primary
                ? AppColors.background
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 20.0, color: _textColor(isDisabled)),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: TextStyle(
            color: _textColor(isDisabled),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    Widget buttonWidget;

    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? AppColors.surfaceLight : null,
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: AppRadius.borderMd,
              onTap: isDisabled ? null : onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(child: child),
              ),
            ),
          ),
        );
        break;

      case AppButtonVariant.secondary:
        buttonWidget = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            color: AppColors.surface,
            border: Border.all(
              color: isDisabled
                  ? AppColors.surfaceBorder
                  : AppColors.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: AppRadius.borderMd,
              onTap: isDisabled ? null : onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(child: child),
              ),
            ),
          ),
        );
        break;

      case AppButtonVariant.text:
        buttonWidget = SizedBox(
          height: height,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
            child: child,
          ),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }

    return buttonWidget;
  }

  Color _textColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.textMuted;
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.background;
      case AppButtonVariant.secondary:
        return AppColors.primary;
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}
