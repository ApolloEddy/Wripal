/// 章节编辑页面
///
/// 使用 flutter_quill 编辑章节正文内容（原生平台）
/// 在 Web 平台使用 WebSafeEditor

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/web_safe_editor.dart';
import '../../application/providers.dart';
import '../../domain/models/chapter.dart';

const _uuid = Uuid();

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
  QuillController? _controller;
  Chapter? _chapter;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  Timer? _autoSaveTimer;
  String? _error;

  /// Web 编辑器 Key（用于获取内容）
  final GlobalKey<WebSafeEditorState> _webEditorKey =
      GlobalKey<WebSafeEditorState>();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    // Web 平台不需要初始化 QuillController
    if (kIsWeb) {
      _loadChapter();
      return;
    }

    try {
      _controller = QuillController.basic();
      _loadChapter();
    } catch (e) {
      setState(() {
        _error = '编辑器初始化失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveContent();
    _controller?.dispose();
    super.dispose();
  }

  /// 加载章节内容
  Future<void> _loadChapter() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      final chapter = await repository.getChapter(widget.chapterId);

      if (chapter == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _chapter = chapter;

      // 如果有关联的文档，加载内容
      if (chapter.contentId != null) {
        // TODO: 从文档仓库加载内容
      }

      if (mounted) setState(() => _isLoading = false);

      // 监听内容变化
      _controller?.document.changes.listen((_) {
        if (!_hasUnsavedChanges && mounted) {
          setState(() => _hasUnsavedChanges = true);
        }
        _scheduleAutoSave();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载章节失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 调度自动保存（防抖 3 秒）
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _saveContent();
    });
  }

  /// 保存内容
  Future<void> _saveContent() async {
    if (!_hasUnsavedChanges || _chapter == null) return;

    // Web 平台检查 _webContent，原生平台检查 _controller
    if (!kIsWeb && _controller == null) return;

    try {
      final repository = ref.read(bookRepositoryProvider);

      String plainText;
      // ignore: unused_local_variable
      String contentJson;

      if (kIsWeb) {
        // Web 平台：通过 GlobalKey 获取编辑器内容
        final editorContent = _webEditorKey.currentState?.text ?? '';
        plainText = editorContent;
        contentJson = editorContent;
        debugPrint('Web 平台保存内容: ${plainText.length} 字符');
      } else {
        // 原生平台：使用 Quill 文档
        plainText = _controller!.document.toPlainText();
        contentJson = jsonEncode(_controller!.document.toDelta().toJson());
      }

      // 计算字数
      final wordCount = plainText.replaceAll(RegExp(r'\s'), '').length;

      // 创建或更新文档内容并获取文档 ID
      final docId = _chapter!.contentId ?? _uuid.v4();

      // TODO: 保存 contentJson 到 RichDocument 仓库
      debugPrint('保存内容: $wordCount 字');

      // 更新章节信息
      final updatedChapter = _chapter!.copyWith(
        contentId: docId,
        wordCount: wordCount,
      );
      await repository.saveChapter(updatedChapter);
      _chapter = updatedChapter;

      if (mounted) setState(() => _hasUnsavedChanges = false);
    } catch (e) {
      debugPrint('保存章节失败: $e');
    }
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
    // Web 平台：跳过 QuillController 检查
    if (!kIsWeb && (_error != null || _controller == null)) {
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
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('章节不存在'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回'),
            ),
          ],
        ),
      );
    }

    // Web 平台使用 WebSafeEditor
    if (kIsWeb) {
      return Column(
        children: [
          // 顶部工具栏
          _buildHeader(context, colorScheme),

          // 编辑器内容
          Expanded(
            child: CardContainer(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(24),
              child: WebSafeEditor(
                key: _webEditorKey,
                placeholder: '开始写作...',
                autoFocus: true,
                onChanged: (_) {
                  if (!_hasUnsavedChanges) {
                    setState(() => _hasUnsavedChanges = true);
                  }
                  _scheduleAutoSave();
                },
              ),
            ),
          ),
        ],
      );
    }

    final controller = _controller!;

    return Column(
      children: [
        // 顶部工具栏
        _buildHeader(context, colorScheme),

        // 编辑器工具栏
        CardContainer(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(),
          ),
        ),

        const SizedBox(height: 8),

        // 编辑器内容
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(24),
            child: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(
                placeholder: '开始写作...',
                padding: EdgeInsets.zero,
                scrollable: true,
                autoFocus: true,
                expands: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建顶部工具栏
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: '返回书籍详情',
          ),

          const SizedBox(width: 12),

          // 章节标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chapter!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_chapter!.wordCount} 字',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),
                    if (_hasUnsavedChanges) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '自动保存中...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 标记完成按钮
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

          // 保存按钮
          FilledButton.icon(
            onPressed: _hasUnsavedChanges ? _saveContent : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 切换完成状态
  Future<void> _toggleCompleted() async {
    if (_chapter == null) return;

    final repository = ref.read(bookRepositoryProvider);
    final updatedChapter = _chapter!.copyWith(
      isCompleted: !_chapter!.isCompleted,
    );
    await repository.saveChapter(updatedChapter);

    setState(() => _chapter = updatedChapter);

    // 刷新章节列表
    ref.read(chaptersProvider(widget.bookId).notifier).loadChapters();
  }
}
