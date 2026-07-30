import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Workspace Typography hierarchy for Kapada Creation Admin.
/// Headlines use Playfair Display (editorial serif).
/// Body/UI uses Montserrat (clean geometric sans-serif).
abstract class AppTypography {
  const AppTypography._();

  // ── Editorial / Serif (Playfair Display) ─────────────────

  static TextStyle get displaySerif => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle get headingSerif => GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle get subheadingSerif => GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get titleSerif => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get italicSerif => GoogleFonts.playfairDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.mutedText,
    height: 1.4,
  );

  // ── Sans-serif (Montserrat) — UI / Body ─────────────────

  static TextStyle get display => GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get pageTitle => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle get sectionTitle => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get cardTitle => GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get bodyLarge => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get body => GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.35,
  );

  static TextStyle get label => GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  static TextStyle get labelUppercase => GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static TextStyle get button => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.surfaceWhite,
    letterSpacing: 0.2,
  );

  static TextStyle get status => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.brandGreen800,
  );

  static TextStyle get metric => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.0,
  );

  static TextStyle get chipLabel => GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
