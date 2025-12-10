/// 响应式侧栏组件
/// 
/// 自适应横屏/竖屏模式，支持展开/收起动画
/// 显示已启用的卡片列表

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_schemes.dart';
import '../../features/base/card_registry.dart';

/// 侧栏展开状态 Provider
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

/// 响应式侧栏组件
class AdaptiveSidebar extends ConsumerWidget {
  const AdaptiveSidebar({super.key});

  /// 侧栏展开宽度
  static const double expandedWidth = 240.0;
  
  /// 侧栏收起宽度
  static const double collapsedWidth = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final cardManager = ref.watch(cardManagerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isExpanded ? expandedWidth : collapsedWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sidebarDark : AppColors.sidebarLight,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部 Logo 区域
          _buildHeader(context, ref, isExpanded),
          
          const SizedBox(height: 8),
          
          // 卡片列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: cardManager.enabledCards.length,
              itemBuilder: (context, index) {
                final card = cardManager.enabledCards[index];
                final isSelected = card.id == cardManager.selectedCardId;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildCardItem(
                    context,
                    ref,
                    card: card,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // 底部操作区
          _buildFooter(context, ref, isExpanded),
        ],
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isExpanded) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withAlpha((0.7 * 255).round()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          // 应用名称（展开时显示）
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wripal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建卡片项
  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref, {
    required dynamic card,
    required bool isSelected,
    required bool isExpanded,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: isSelected 
          ? colorScheme.primary.withAlpha((0.12 * 255).round())
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref.read(cardManagerProvider.notifier).selectCard(card.id);
        },
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 12 : 0,
          ),
          child: Row(
            mainAxisAlignment: isExpanded 
                ? MainAxisAlignment.start 
                : MainAxisAlignment.center,
            children: [
              Icon(
                card.icon,
                size: 22,
                color: isSelected 
                    ? colorScheme.primary 
                    : colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? colorScheme.primary 
                          : colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建底部区域
  Widget _buildFooter(BuildContext context, WidgetRef ref, bool isExpanded) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: isExpanded 
            ? MainAxisAlignment.spaceBetween 
            : MainAxisAlignment.center,
        children: [
          // 展开/收起按钮
          IconButton(
            icon: Icon(
              isExpanded 
                  ? Icons.chevron_left_rounded 
                  : Icons.chevron_right_rounded,
            ),
            onPressed: () {
              ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
            },
            tooltip: isExpanded ? '收起侧栏' : '展开侧栏',
          ),
          
          // 设置按钮（展开时显示）
          if (isExpanded)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // TODO: 打开设置
              },
              tooltip: '设置',
            ),
        ],
      ),
    );
  }
}
