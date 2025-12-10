/// 可拔插卡片系统 - 卡片基类
/// 
/// 定义所有功能卡片必须实现的抽象接口
/// 卡片是 Wripal 的核心扩展机制，每个功能模块都封装为一个卡片

import 'package:flutter/material.dart';

/// 卡片类型枚举
enum CardType {
  /// 手写笔记
  handwriting,
  
  /// 富文本编辑器
  richEditor,
  
  /// 文件管理
  fileManager,
  
  /// 用户配置
  userProfile,
  
  /// 设置
  settings,
}

/// 功能卡片抽象基类
/// 
/// 所有可拔插的功能模块都必须继承此类
abstract class FeatureCard {
  /// 卡片唯一标识符
  String get id;

  /// 卡片显示名称
  String get name;

  /// 卡片图标
  IconData get icon;

  /// 卡片类型
  CardType get type;

  /// 卡片描述
  String get description;

  /// 是否默认启用
  bool get enabledByDefault;

  /// 卡片排序权重（越小越靠前）
  int get sortOrder;

  /// 构建卡片内容 Widget
  /// 
  /// [context] Flutter 构建上下文
  Widget buildContent(BuildContext context);

  /// 构建侧栏中的卡片项 Widget
  /// 
  /// [context] Flutter 构建上下文
  /// [isSelected] 是否当前选中
  /// [onTap] 点击回调
  Widget buildSidebarItem(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : null,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// 卡片初始化
  /// 
  /// 当卡片首次被加载时调用，用于初始化资源
  Future<void> initialize() async {}

  /// 卡片销毁
  /// 
  /// 当卡片被卸载时调用，用于释放资源
  Future<void> dispose() async {}

  /// 获取卡片当前状态用于持久化
  Map<String, dynamic> getState() => {};

  /// 从持久化状态恢复卡片
  void restoreState(Map<String, dynamic> state) {}
}
