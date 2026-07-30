import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTheme definition for Kapada Creation Admin Workspace.
/// Uses Playfair Display (serif editorial headings) + Montserrat (clean UI body).
abstract class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.brandGreen800,
      scaffoldBackgroundColor: AppColors.warmIvory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandGreen800,
        onPrimary: AppColors.surfaceWhite,
        secondary: AppColors.brandGreen600,
        onSecondary: AppColors.surfaceWhite,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.charcoal,
        error: AppColors.error,
        onError: AppColors.surfaceWhite,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
          letterSpacing: -0.3,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.charcoal,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.charcoal,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedText,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedText,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText,
          letterSpacing: 0.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brandGreen900,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.surfaceWhite,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: AppColors.brandGreen50,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.brandGreen900,
              size: 22,
            );
          }
          return const IconThemeData(color: AppColors.mutedText, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen900,
              letterSpacing: 0.3,
            );
          }
          return GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softCream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.brandGreen800,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: AppColors.mutedText,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: AppColors.mutedText,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen800,
          foregroundColor: AppColors.surfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandGreen800,
          side: const BorderSide(color: AppColors.brandGreen800, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen800,
          textStyle: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.brandGreen900,
        selectedIconTheme: IconThemeData(color: AppColors.surfaceWhite),
        unselectedIconTheme: IconThemeData(color: AppColors.brandGreen100),
        indicatorColor: AppColors.brandGreen700,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.brandGreen50,
        selectedColor: AppColors.brandGreen100,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.brandGreen900,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.brandGreen900,
        contentTextStyle: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.surfaceWhite,
        ),
        actionTextColor: AppColors.mutedGold,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
