import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

/// Reusable generic loading state view with skeleton shimmer for lists, cards, and details.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message = 'Loading...',
    this.useShimmer = true,
    this.itemCount = 4,
    this.type = AppLoadingType.list,
  });

  final String message;
  final bool useShimmer;
  final int itemCount;
  final AppLoadingType type;

  @override
  Widget build(BuildContext context) {
    if (!useShimmer) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return switch (type) {
      AppLoadingType.list => _buildListSkeleton(),
      AppLoadingType.grid => _buildGridSkeleton(),
      AppLoadingType.card => _buildCardSkeleton(),
      AppLoadingType.details => _buildDetailsSkeleton(),
    };
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            height: 76,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderLg,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                _buildShimmerBox(width: 44, height: 44, radius: 12),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerBox(width: 140, height: 12, radius: 4),
                      const SizedBox(height: 8),
                      _buildShimmerBox(width: 90, height: 10, radius: 4),
                    ],
                  ),
                ),
                _buildShimmerBox(width: 50, height: 22, radius: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 110, height: 12, radius: 4),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 60, height: 10, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(width: 160, height: 16, radius: 4),
            const SizedBox(height: AppSpacing.md),
            _buildShimmerBox(width: double.infinity, height: 12, radius: 4),
            const SizedBox(height: AppSpacing.xs),
            _buildShimmerBox(width: 220, height: 12, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(width: double.infinity, height: 220, radius: 20),
          const SizedBox(height: AppSpacing.lg),
          _buildShimmerBox(width: 180, height: 20, radius: 4),
          const SizedBox(height: AppSpacing.sm),
          _buildShimmerBox(width: 120, height: 14, radius: 4),
          const SizedBox(height: AppSpacing.xl),
          _buildShimmerBox(width: double.infinity, height: 80, radius: 12),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(radius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        );
  }
}

enum AppLoadingType { list, grid, card, details }

/// Reusable generic empty state view prepared for future SVG assets.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.svgAssetPath,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? svgAssetPath;
  final Widget? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            _buildIconOrSvg(size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustrationOrIconContainer(),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderLg,
                  ),
                  elevation: 0,
                ),
                icon: PhosphorIcon(PhosphorIcons.plus(), size: 18),
                label: Text(
                  actionLabel!,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationOrIconContainer() {
    if (illustration != null) return illustration!;
    if (svgAssetPath != null && svgAssetPath!.isNotEmpty) {
      return SvgPicture.asset(svgAssetPath!, width: 120, height: 120);
    }

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Icon(
        icon ?? PhosphorIcons.tray(),
        size: 32,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildIconOrSvg({required double size}) {
    if (svgAssetPath != null && svgAssetPath!.isNotEmpty) {
      return SvgPicture.asset(svgAssetPath!, width: size, height: size);
    }
    return Icon(
      icon ?? PhosphorIcons.fileX(),
      color: AppColors.primary,
      size: size,
    );
  }
}

/// Reusable generic error state view prepared for future SVG assets and debug details.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.debugDetails,
    this.svgAssetPath,
    this.illustration,
    this.onRetry,
  });

  final String title;
  final String message;
  final String? debugDetails;
  final String? svgAssetPath;
  final Widget? illustration;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null)
              illustration!
            else if (svgAssetPath != null && svgAssetPath!.isNotEmpty)
              SvgPicture.asset(svgAssetPath!, width: 120, height: 120)
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: PhosphorIcon(
                  PhosphorIcons.warningCircle(),
                  size: 36,
                  color: AppColors.error,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
            if (debugDetails != null && debugDetails!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                debugDetails!,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderLg,
                  ),
                  elevation: 0,
                ),
                icon: PhosphorIcon(PhosphorIcons.arrowsCounterClockwise(), size: 18),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
