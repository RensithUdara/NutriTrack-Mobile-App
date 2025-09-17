import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color primaryOrange = Color(0xFFE65100);
  static const Color primaryOrangeDark = Color(0xFFBF360C);
  static const Color accentOrange = Color(0xFFFF6F00);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color darkOrange = Color(0xFFD84315);

  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOnBackground = Color(0xFF1C1B1F);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkOnBackground = Color(0xFFE1E1E1);

  // Text styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        onPrimary: Colors.white,
        secondary: accentOrange,
        onSecondary: Colors.white,
        tertiary: warningOrange,
        onTertiary: Colors.white,
        error: errorRed,
        onError: Colors.white,
        background: lightBackground,
        onBackground: lightOnBackground,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceVariant: lightOrange,
        onSurfaceVariant: primaryOrangeDark,
        outline: Color(0xFF79747E),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF313033),
        onInverseSurface: Color(0xFFF4EFF4),
        inversePrimary: accentOrange,
      ),
      textTheme: TextTheme(
        headlineLarge: headlineLarge.copyWith(color: lightOnBackground),
        headlineMedium: headlineMedium.copyWith(color: lightOnBackground),
        headlineSmall: headlineSmall.copyWith(color: lightOnBackground),
        titleLarge: titleLarge.copyWith(color: lightOnBackground),
        titleMedium: titleMedium.copyWith(color: lightOnBackground),
        titleSmall: titleSmall.copyWith(color: lightOnBackground),
        bodyLarge: bodyLarge.copyWith(color: lightOnBackground),
        bodyMedium: bodyMedium.copyWith(color: lightOnBackground),
        bodySmall: bodySmall.copyWith(color: lightOnBackground),
        labelLarge: labelLarge.copyWith(color: lightOnBackground),
        labelMedium: labelMedium.copyWith(color: lightOnBackground),
        labelSmall: labelSmall.copyWith(color: lightOnBackground),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        titleTextStyle: titleLarge.copyWith(color: lightOnSurface),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: lightSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: lightSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Color(0xFF79747E),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: lightSurface,
        indicatorColor: lightOrange,
        labelTextStyle: WidgetStateProperty.all(
          labelSmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightOrange.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: bodyMedium.copyWith(color: Color(0xFF79747E)),
        hintStyle: bodyMedium.copyWith(color: Color(0xFF79747E)),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentOrange,
        onPrimary: Colors.black,
        secondary: primaryOrange,
        onSecondary: Colors.white,
        tertiary: warningOrange,
        onTertiary: Colors.black,
        error: errorRed,
        onError: Colors.white,
        background: darkBackground,
        onBackground: darkOnBackground,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceVariant: Color(0xFF1A1A1A),
        onSurfaceVariant: Color(0xFFB8B8B8),
        outline: Color(0xFF79747E),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE1E1E1),
        onInverseSurface: Color(0xFF313033),
        inversePrimary: primaryOrange,
      ),
      textTheme: TextTheme(
        headlineLarge: headlineLarge.copyWith(color: darkOnBackground),
        headlineMedium: headlineMedium.copyWith(color: darkOnBackground),
        headlineSmall: headlineSmall.copyWith(color: darkOnBackground),
        titleLarge: titleLarge.copyWith(color: darkOnBackground),
        titleMedium: titleMedium.copyWith(color: darkOnBackground),
        titleSmall: titleSmall.copyWith(color: darkOnBackground),
        bodyLarge: bodyLarge.copyWith(color: darkOnBackground),
        bodyMedium: bodyMedium.copyWith(color: darkOnBackground),
        bodySmall: bodySmall.copyWith(color: darkOnBackground),
        labelLarge: labelLarge.copyWith(color: darkOnBackground),
        labelMedium: labelMedium.copyWith(color: darkOnBackground),
        labelSmall: labelSmall.copyWith(color: darkOnBackground),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        titleTextStyle: titleLarge.copyWith(color: darkOnSurface),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: darkSurface,
        selectedItemColor: accentOrange,
        unselectedItemColor: Color(0xFF79747E),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: darkSurface,
        indicatorColor: Color(0xFF1A1A1A),
        labelTextStyle: WidgetStateProperty.all(
          labelSmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: bodyMedium.copyWith(color: Color(0xFF79747E)),
        hintStyle: bodyMedium.copyWith(color: Color(0xFF79747E)),
      ),
    );
  }
}
