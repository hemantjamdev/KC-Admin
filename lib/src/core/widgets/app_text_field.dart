import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

/// Reusable premium text field for Kapada Creation applications.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          onChanged: onChanged,
          onFieldSubmitted:
              onFieldSubmitted ??
              (value) {
                final action = textInputAction ?? TextInputAction.next;
                if (action == TextInputAction.next) {
                  FocusScope.of(context).nextFocus();
                } else if (action == TextInputAction.done) {
                  FocusScope.of(context).unfocus();
                }
              },
          enabled: enabled,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15.0),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 15.0,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 12.0),
          ),
        ),
      ],
    );
  }
}
