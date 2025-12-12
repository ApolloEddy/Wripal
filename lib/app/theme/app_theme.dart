/// Wripal 应用主题配置
///
/// 定义应用的亮色/暗色主题，采用圆角 + 拟态设计风格

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_schemes.dart';

/// 应用主题管理类
class AppTheme {
  AppTheme._();

  /// 圆角半径常量
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  /// 拟态阴影配置
  static List<BoxShadow> neumorphicShadowLight = [
    BoxShadow(
      color: Colors.white.withAlpha((0.8 * 255).round()),
      offset: const Offset(-4, -4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.black.withAlpha((0.1 * 255).round()),
      offset: const Offset(4, 4),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> neumorphicShadowDark = [
    BoxShadow(
      color: Colors.white.withAlpha((0.05 * 255).round()),
      offset: const Offset(-4, -4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.black.withAlpha((0.4 * 255).round()),
      offset: const Offset(4, 4),
      blurRadius: 8,
    ),
  ];

  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: AppColors.lightSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: AppColors.darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
    );
  }

  /// 文本主题
  static TextTheme get _textTheme {
    return GoogleFonts.notoSansScTextTheme().copyWith(
      displayLarge: GoogleFonts.notoSansSc(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.notoSansSc(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.notoSansSc(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.notoSansSc(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.notoSansSc(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
