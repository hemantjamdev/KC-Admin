import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

/// Reusable design-system Slide-to-Action button for confirmation flows.
class SlideToActionButton extends StatefulWidget {
  const SlideToActionButton({
    super.key,
    required this.label,
    required this.onSlideComplete,
    this.backgroundColor,
    this.sliderColor,
    this.textColor,
    this.borderColor,
    this.iconColor,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onSlideComplete;
  final Color? backgroundColor;
  final Color? sliderColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? iconColor;
  final IconData? icon;
  final bool isLoading;

  @override
  State<SlideToActionButton> createState() => _SlideToActionButtonState();
}

class _SlideToActionButtonState extends State<SlideToActionButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - 68;
        final themeColor = widget.sliderColor ?? AppColors.primary;
        final bgColor = widget.backgroundColor ?? AppColors.primary;

        return Container(
          height: 68,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: widget.borderColor ?? Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track Label & Loading state
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 64, right: 24),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: widget.textColor ?? Colors.white,
                          ),
                        )
                      : Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: widget.textColor ?? Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              // Sliding Thumb Button (Icon Only)
              Positioned(
                left: _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: widget.isLoading
                      ? null
                      : (details) {
                          setState(() {
                            _dragValue += details.delta.dx;
                            _dragValue = _dragValue.clamp(0.0, maxDrag);
                          });
                        },
                  onHorizontalDragEnd: widget.isLoading
                      ? null
                      : (details) {
                          if (_dragValue >= maxDrag * 0.68) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _dragValue = maxDrag;
                            });
                            widget.onSlideComplete();
                            // Reset slider position after trigger
                            Future.delayed(const Duration(milliseconds: 600), () {
                              if (mounted) setState(() => _dragValue = 0.0);
                            });
                          } else {
                            setState(() {
                              _dragValue = 0.0;
                            });
                          }
                        },
                  child: Container(
                    width: 58,
                    height: 58,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        widget.icon ?? PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                        size: 24,
                        color: widget.iconColor ?? Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
