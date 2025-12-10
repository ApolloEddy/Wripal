/// 主布局容器
/// 
/// 应用的根布局，包含侧栏和内容区域

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'adaptive_sidebar.dart';
import '../../features/base/card_registry.dart';

/// 主布局容器
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // 初始化卡片管理器
    Future.microtask(() {
      ref.read(cardManagerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardManager = ref.watch(cardManagerProvider);
    final selectedCard = cardManager.selectedCard;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // 侧栏
            const AdaptiveSidebar(),
            
            // 内容区域
            Expanded(
              child: _buildContentArea(selectedCard),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContentArea(dynamic selectedCard) {
    if (selectedCard == null) {
      return _buildEmptyState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: selectedCard.buildContent(context),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            '选择一个功能开始使用',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '从左侧边栏选择手写笔记或富文本编辑器',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline.withAlpha((0.7 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}
