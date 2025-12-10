/// Wripal 路由定义
/// 
/// 使用声明式路由管理应用页面导航

import 'package:flutter/material.dart';

/// 路由名称常量
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String handwriting = '/handwriting';
  static const String richEditor = '/editor';
  static const String settings = '/settings';
}

/// 路由配置（预留，后续可扩展为 GoRouter）
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        // TODO: 返回主页面
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
