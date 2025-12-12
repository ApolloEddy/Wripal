/// 书籍详情页面
///
/// 展示书籍的详细信息，使用 Tab 切换章节、大纲、角色和情节视图

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../application/providers.dart';
import '../../domain/models/book.dart';
import '../widgets/chapter_list.dart';
import '../widgets/character_list.dart';
import '../widgets/plot_timeline.dart';
import '../widgets/outline_editor.dart';

/// 书籍详情页面
class BookDetailPage extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  int _currentTabIndex = 0;
  // 记录哪些 Tab 已经被访问过（用于懒加载）
  final Set<int> _loadedTabs = {0};

  @override
  void initState() {
    super.initState();
    // 加载章节列表
    Future.microtask(() {
      ref.read(chaptersProvider(widget.bookId).notifier).loadChapters();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
      _loadedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(selectedBookProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('书籍详情')),
        body: const Center(child: Text('书籍不存在')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部信息栏
            _buildHeader(context, book, colorScheme),

            // Tab 栏
            _buildTabBar(context, colorScheme),

            // Tab 内容（懒加载，只渲染当前选中的）
            Expanded(child: _buildLazyTabContent()),
          ],
        ),
      ),
    );
  }

  /// 构建懒加载的 Tab 内容
  Widget _buildLazyTabContent() {
    // 只渲染当前选中的 Tab，其他 Tab 使用空容器
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        // 章节列表 - 始终加载（默认 Tab）
        ChapterList(bookId: widget.bookId),

        // 大纲编辑器 - 懒加载
        _loadedTabs.contains(1)
            ? OutlineEditor(bookId: widget.bookId)
            : const SizedBox.shrink(),

        // 角色列表 - 懒加载
        _loadedTabs.contains(2)
            ? CharacterList(bookId: widget.bookId)
            : const SizedBox.shrink(),

        // 情节时间线 - 懒加载
        _loadedTabs.contains(3)
            ? PlotTimeline(bookId: widget.bookId)
            : const SizedBox.shrink(),
      ],
    );
  }

  /// 构建顶部信息栏
  Widget _buildHeader(
    BuildContext context,
    Book book,
    ColorScheme colorScheme,
  ) {
    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '返回书架',
          ),

          const SizedBox(width: 12),

          // 书籍信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(book.status),
                  ],
                ),
                if (book.description != null && book.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      book.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 统计信息
          _buildStatItem(
            context,
            icon: Icons.layers_outlined,
            label: '章节',
            value: '${book.chapterIds.length}',
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            context,
            icon: Icons.people_outline,
            label: '角色',
            value: '${book.characterIds.length}',
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            context,
            icon: Icons.timeline_outlined,
            label: '情节',
            value: '${book.plotPointIds.length}',
          ),

          const SizedBox(width: 16),

          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditBookDialog(context, book),
            tooltip: '编辑书籍信息',
          ),
        ],
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(BookStatus status) {
    final (label, color) = switch (status) {
      BookStatus.draft => ('草稿', Colors.grey),
      BookStatus.writing => ('写作中', Colors.blue),
      BookStatus.completed => ('已完成', Colors.green),
      BookStatus.archived => ('已归档', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: colorScheme.outline)),
      ],
    );
  }

  /// 构建 Tab 栏
  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton(
            context,
            index: 0,
            icon: Icons.layers_outlined,
            label: '章节',
            colorScheme: colorScheme,
          ),
          _buildTabButton(
            context,
            index: 1,
            icon: Icons.subject_outlined,
            label: '大纲',
            colorScheme: colorScheme,
          ),
          _buildTabButton(
            context,
            index: 2,
            icon: Icons.people_outline,
            label: '角色',
            colorScheme: colorScheme,
          ),
          _buildTabButton(
            context,
            index: 3,
            icon: Icons.timeline_outlined,
            label: '情节',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示编辑书籍对话框
  Future<void> _showEditBookDialog(BuildContext context, Book book) async {
    final titleController = TextEditingController(text: book.title);
    final descriptionController = TextEditingController(
      text: book.description ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑书籍'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '书籍标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '书籍简介',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final updatedBook = book.copyWith(
        title: titleController.text,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
      );
      await ref.read(booksProvider.notifier).updateBook(updatedBook);
    }

    titleController.dispose();
    descriptionController.dispose();
  }
}
