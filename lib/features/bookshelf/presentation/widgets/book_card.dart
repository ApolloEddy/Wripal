/// 书籍卡片组件
///
/// 在书架网格中展示单本书籍的卡片，包含封面、标题、进度等信息

import 'package:flutter/material.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../domain/models/book.dart';

/// 书籍卡片组件
class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _isHovered ? 1.02 : 1.0,
          child: CardContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 封面区域
                Expanded(
                  flex: 3,
                  child: _buildCover(context, colorScheme, isDark),
                ),

                // 信息区域
                Expanded(flex: 2, child: _buildInfo(context, colorScheme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建封面区域
  Widget _buildCover(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // 根据书籍标题生成渐变色
    final hue = (widget.book.title.hashCode % 360).abs().toDouble();
    final gradientColors = [
      HSLColor.fromAHSL(1, hue, 0.6, isDark ? 0.3 : 0.7).toColor(),
      HSLColor.fromAHSL(1, (hue + 30) % 360, 0.5, isDark ? 0.2 : 0.5).toColor(),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        // 封面背景
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.book.coverImagePath != null
                  ? [colorScheme.surfaceContainerHighest, colorScheme.surface]
                  : gradientColors,
            ),
          ),
          child: widget.book.coverImagePath != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    widget.book.coverImagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultCover(colorScheme),
                  ),
                )
              : _buildDefaultCover(colorScheme),
        ),

        // 状态标签
        Positioned(top: 8, right: 8, child: _buildStatusBadge(context)),

        // 悬浮操作按钮
        if (_isHovered)
          Positioned(top: 8, left: 8, child: _buildDeleteButton(context)),
      ],
    );
  }

  /// 构建默认封面
  Widget _buildDefaultCover(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: Colors.white.withAlpha(180),
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusBadge(BuildContext context) {
    final (label, color) = switch (widget.book.status) {
      BookStatus.draft => ('草稿', Colors.grey),
      BookStatus.writing => ('写作中', Colors.blue),
      BookStatus.completed => ('已完成', Colors.green),
      BookStatus.archived => ('已归档', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建删除按钮
  Widget _buildDeleteButton(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onDelete,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.delete_outline, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  /// 构建信息区域
  Widget _buildInfo(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            widget.book.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 描述
          Expanded(
            child: Text(
              widget.book.description ?? '暂无简介',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 章节数和更新时间
          Row(
            children: [
              Icon(Icons.layers_outlined, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                '${widget.book.chapterIds.length} 章',
                style: TextStyle(fontSize: 11, color: colorScheme.outline),
              ),
              const Spacer(),
              Text(
                _formatDate(widget.book.updatedAt),
                style: TextStyle(fontSize: 11, color: colorScheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
