import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

/// Reusable design-system AppBar for all screens in KC-Admin (Admin App).
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.showBackButton = true,
    this.onBackTap,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
    this.showBottomDivider = false,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBottomDivider;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final shouldShowBack = showBackButton && (canPop || onBackTap != null);

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: shouldShowBack
          ? IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                size: 20,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Back',
              onPressed: onBackTap ?? () => Navigator.maybePop(context),
            )
          : null,
      title:
          titleWidget ??
          (title != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.montserrat(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                )
              : null),
      actions: actions != null ? [...actions!, const SizedBox(width: 8)] : null,
      bottom:
          bottom ??
          (showBottomDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                    height: 1.0,
                  ),
                )
              : null),
    );
  }
}
