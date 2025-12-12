/// 章节编辑页面
///
/// 使用 ChapterRichEditor (flutter_quill) 编辑章节正文内容

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/chapter_rich_editor.dart';
import '../../application/providers.dart';
import '../../domain/models/chapter.dart';

/// 章节编辑页面
class ChapterEditorPage extends ConsumerStatefulWidget {
  final String bookId;
  final String chapterId;

  const ChapterEditorPage({
    super.key,
    required this.bookId,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterEditorPage> createState() => _ChapterEditorPageState();
}

class _ChapterEditorPageState extends ConsumerState<ChapterEditorPage> {
  Chapter? _chapter;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  Timer? _autoSaveTimer;
  String? _error;

  final GlobalKey<ChapterRichEditorState> _editorKey =
      GlobalKey<ChapterRichEditorState>();

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      final chapter = await repository.getChapter(widget.chapterId);

      if (chapter == null) {
        if (mounted) {
          setState(() {
            _error = '章节未找到';
            _isLoading = false;
          });
        }
        return;
      }

      _chapter = chapter;
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载章节失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveContentSync();
    super.dispose();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _saveContent();
    });
  }

  void _saveContentSync() {
    if (!_hasUnsavedChanges || _chapter == null) return;

    final editorState = _editorKey.currentState;
    if (editorState == null) return;

    final content = editorState.getContent();
    final plainText = editorState.text;
    final wordCount = plainText.trim().length;

    final repository = ref.read(bookRepositoryProvider);
    final updatedChapter = _chapter!.copyWith(
      content: content,
      wordCount: wordCount,
    );
    repository.saveChapter(updatedChapter);
    debugPrint('同步保存内容: $wordCount 字');
  }

  Future<void> _saveContent() async {
    if (!_hasUnsavedChanges || _chapter == null) return;

    try {
      final repository = ref.read(bookRepositoryProvider);
      final editorState = _editorKey.currentState;
      if (editorState == null) return;

      final content = editorState.getContent();
      final plainText = editorState.text;
      final wordCount = plainText.trim().length;

      debugPrint('保存内容: $wordCount 字');

      final updatedChapter = _chapter!.copyWith(
        content: content,
        wordCount: wordCount,
      );
      await repository.saveChapter(updatedChapter);
      _chapter = updatedChapter;

      if (mounted) setState(() => _hasUnsavedChanges = false);
    } catch (e) {
      debugPrint('保存章节失败: $e');
    }
  }

  Future<void> _toggleCompleted() async {
    if (_chapter == null) return;

    final repository = ref.read(bookRepositoryProvider);
    final updatedChapter = _chapter!.copyWith(
      isCompleted: !_chapter!.isCompleted,
    );
    await repository.saveChapter(updatedChapter);
    setState(() => _chapter = updatedChapter);
    ref.read(chaptersProvider(widget.bookId).notifier).loadChapters();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, colorScheme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(_error ?? '编辑器初始化失败'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回'),
            ),
          ],
        ),
      );
    }

    if (_chapter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('章节未找到'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 顶部状态栏
        _buildHeader(context, colorScheme),

        // 编辑器（内置工具栏）
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ChapterRichEditor(
                key: _editorKey,
                initialContent: _chapter?.content,
                placeholder: '开始写作...',
                autoFocus: true,
                showToolbar: true,
                onChanged: (_) {
                  if (!_hasUnsavedChanges) {
                    setState(() => _hasUnsavedChanges = true);
                  }
                  _scheduleAutoSave();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: '返回书籍详情',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chapter!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _hasUnsavedChanges
                      ? '未保存 · ${_chapter!.wordCount} 字'
                      : '已保存 · ${_chapter!.wordCount} 字',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _hasUnsavedChanges
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _chapter!.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: _chapter!.isCompleted ? Colors.green : null,
            ),
            onPressed: _toggleCompleted,
            tooltip: _chapter!.isCompleted ? '标记为未完成' : '标记为已完成',
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _hasUnsavedChanges ? _saveContent : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
