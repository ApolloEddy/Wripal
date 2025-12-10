/// Wripal 应用颜色方案
/// 
/// 定义应用的统一颜色方案，支持亮色和暗色模式

import 'package:flutter/material.dart';

/// 应用统一颜色定义
class AppColors {
  AppColors._();

  // 主色调 - 优雅的靛蓝色
  static const Color primary = Color(0xFF5C6BC0);
  static const Color primaryLight = Color(0xFF8E99F3);
  static const Color primaryDark = Color(0xFF26418F);

  // 次要色调 - 温暖的琥珀色
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryLight = Color(0xFFFFE97D);
  static const Color secondaryDark = Color(0xFFC88719);

  // 强调色 - 活力绿
  static const Color accent = Color(0xFF66BB6A);

  // 错误色
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFFF867C);
  static const Color errorDark = Color(0xFFB61827);

  // 成功色
  static const Color success = Color(0xFF4CAF50);

  // 警告色
  static const Color warning = Color(0xFFFFA726);

  // 信息色
  static const Color info = Color(0xFF29B6F6);

  // 亮色模式背景
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOnBackground = Color(0xFF2D2D44);

  // 暗色模式背景
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkOnSurface = Color(0xFFE4E4E7);
  static const Color darkOnBackground = Color(0xFFC8C8D0);

  // 侧边栏颜色
  static const Color sidebarLight = Color(0xFFEEEFF5);
  static const Color sidebarDark = Color(0xFF16161E);

  // 画布颜色
  static const Color canvasLight = Color(0xFFFFFDF7);
  static const Color canvasDark = Color(0xFF1A1A1A);

  // 笔触预设颜色
  static const List<Color> strokeColors = [
    Color(0xFF1A1A2E), // 深灰黑
    Color(0xFF5C6BC0), // 靛蓝
    Color(0xFFEF5350), // 红
    Color(0xFF66BB6A), // 绿
    Color(0xFF29B6F6), // 蓝
    Color(0xFFFFB74D), // 橙
    Color(0xFFAB47BC), // 紫
    Color(0xFF26A69A), // 青
  ];

  // 亮色主题 ColorScheme
  static ColorScheme get lightColorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: secondary,
        onSecondary: Colors.black87,
        secondaryContainer: secondaryLight,
        onSecondaryContainer: secondaryDark,
        tertiary: accent,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceContainerHighest: lightBackground,
        onSurfaceVariant: lightOnBackground,
        outline: const Color(0xFFD0D0D8),
        outlineVariant: const Color(0xFFE8E8EC),
      );

  // 暗色主题 ColorScheme
  static ColorScheme get darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: secondary,
        onSecondary: Colors.black87,
        secondaryContainer: secondaryDark,
        onSecondaryContainer: secondaryLight,
        tertiary: accent,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkBackground,
        onSurfaceVariant: darkOnBackground,
        outline: const Color(0xFF3A3A4A),
        outlineVariant: const Color(0xFF2A2A3A),
      );
}
