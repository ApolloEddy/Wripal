/// 章节列表组件
///
/// 展示书籍的所有章节，支持创建、编辑、删除和拖拽排序

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../application/providers.dart';
import '../../domain/models/chapter.dart';
import '../pages/chapter_editor_page.dart';

/// 章节列表组件
class ChapterList extends ConsumerWidget {
  final String bookId;

  const ChapterList({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersState = ref.watch(chaptersProvider(bookId));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                '共 ${chaptersState.chapters.length} 章',
                style: TextStyle(color: colorScheme.outline),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreateChapterDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建章节'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 章节列表
        Expanded(child: _buildChapterList(context, ref, chaptersState)),
      ],
    );
  }

  /// 构建章节列表
  Widget _buildChapterList(
    BuildContext context,
    WidgetRef ref,
    ChaptersState chaptersState,
  ) {
    if (chaptersState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chaptersState.chapters.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: chaptersState.chapters.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        ref
            .read(chaptersProvider(bookId).notifier)
            .reorderChapters(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final chapter = chaptersState.chapters[index];
        return _ChapterListTile(
          key: ValueKey(chapter.id),
          chapter: chapter,
          index: index,
          onTap: () => _openChapterEditor(context, ref, chapter),
          onDelete: () => _deleteChapter(context, ref, chapter),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text('还没有创建任何章节', style: TextStyle(color: colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => _showCreateChapterDialog(context, ref),
            child: const Text('创建第一章'),
          ),
        ],
      ),
    );
  }

  /// 显示创建章节对话框
  Future<void> _showCreateChapterDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建章节'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '章节标题',
            hintText: '输入章节名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('创建'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      await ref
          .read(chaptersProvider(bookId).notifier)
          .createChapter(title: titleController.text);
    }

    titleController.dispose();
  }

  /// 打开章节编辑器
  void _openChapterEditor(
    BuildContext context,
    WidgetRef ref,
    Chapter chapter,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ChapterEditorPage(bookId: bookId, chapterId: chapter.id),
      ),
    );
  }

  /// 删除章节
  Future<void> _deleteChapter(
    BuildContext context,
    WidgetRef ref,
    Chapter chapter,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除章节'),
        content: Text('确定要删除《${chapter.title}》吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(chaptersProvider(bookId).notifier)
          .deleteChapter(chapter.id);
    }
  }
}

/// 章节列表项
class _ChapterListTile extends StatelessWidget {
  final Chapter chapter;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChapterListTile({
    super.key,
    required this.chapter,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CardContainer(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chapter.isCompleted
                  ? Colors.green.withAlpha(30)
                  : colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: chapter.isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 20)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
            ),
          ),
          title: Text(
            chapter.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.text_fields, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                '${chapter.wordCount} 字',
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                _formatDate(chapter.updatedAt),
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: onDelete,
                tooltip: '删除章节',
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
