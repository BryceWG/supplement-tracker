import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  static const primary = Color(0xFF3EBB7F);
  static const primaryDark = Color(0xFF339968);
  static const primaryLight = Color(0xFFE8F5EE);

  static const List<String> _cjkFontFallback = [
    'Microsoft YaHei UI',
    'Microsoft YaHei',
    'Segoe UI',
    'PingFang SC',
    'Hiragino Sans GB',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Arial',
  ];

  static String? _preferredFontFamily() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 'Microsoft YaHei UI';
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        return 'PingFang SC';
      case TargetPlatform.linux:
        return 'Noto Sans CJK SC';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static TextTheme _withFont(TextTheme base, {required String? fontFamily}) {
    TextStyle? style(TextStyle? s) {
      if (s == null) return null;
      return s.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: _cjkFontFallback,
      );
    }

    return base.copyWith(
      displayLarge: style(base.displayLarge),
      displayMedium: style(base.displayMedium),
      displaySmall: style(base.displaySmall),
      headlineLarge: style(base.headlineLarge),
      headlineMedium: style(base.headlineMedium),
      headlineSmall: style(base.headlineSmall),
      titleLarge: style(base.titleLarge),
      titleMedium: style(base.titleMedium),
      titleSmall: style(base.titleSmall),
      bodyLarge: style(base.bodyLarge),
      bodyMedium: style(base.bodyMedium),
      bodySmall: style(base.bodySmall),
      labelLarge: style(base.labelLarge),
      labelMedium: style(base.labelMedium),
      labelSmall: style(base.labelSmall),
    );
  }

  static ThemeData lightTheme() {
    final fontFamily = _preferredFontFamily();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: primaryDark,
      surface: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xF2FFFFFF),
        foregroundColor: Color(0xFF1D1D1D),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    return base.copyWith(
      textTheme: _withFont(base.textTheme, fontFamily: fontFamily),
      primaryTextTheme: _withFont(base.primaryTextTheme, fontFamily: fontFamily),
    );
  }
}
