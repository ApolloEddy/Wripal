/// 应用常量定义
/// 
/// 统一管理应用中使用的各种常量值

/// 应用基础常量
class AppConstants {
  AppConstants._();

  /// 应用名称
  static const String appName = 'Wripal';

  /// 应用版本
  static const String appVersion = '0.1.0';

  /// 最大笔触点数（超过后分段）
  static const int maxStrokePoints = 1000;

  /// 自动保存间隔（毫秒）
  static const int autoSaveInterval = 3000;

  /// 最大撤销步数
  static const int maxUndoSteps = 50;
}

/// 存储相关常量
class StorageKeys {
  StorageKeys._();

  /// 主题模式
  static const String themeMode = 'theme_mode';

  /// 启用的卡片列表
  static const String enabledCards = 'enabled_cards';

  /// 当前选中的卡片
  static const String selectedCard = 'selected_card';

  /// 笔触数据 Box 名称
  static const String strokesBox = 'strokes_box';

  /// 文档数据 Box 名称
  static const String documentsBox = 'documents_box';
}

/// 绘图相关常量
class DrawingConstants {
  DrawingConstants._();

  /// 默认笔触宽度
  static const double defaultStrokeWidth = 2.0;

  /// 最小笔触宽度
  static const double minStrokeWidth = 0.5;

  /// 最大笔触宽度
  static const double maxStrokeWidth = 20.0;

  /// 橡皮擦宽度
  static const double eraserWidth = 20.0;

  /// 默认压感系数
  static const double defaultPressureFactor = 1.0;
}
