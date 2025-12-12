/// 大纲编辑器组件
///
/// 在原生平台使用 flutter_quill，在 Web 平台使用简单编辑器

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/web_safe_editor.dart';
import '../../application/providers.dart';
import '../../domain/models/outline.dart';

const _uuid = Uuid();

/// 大纲编辑器组件
class OutlineEditor extends ConsumerStatefulWidget {
  final String bookId;

  const OutlineEditor({super.key, required this.bookId});

  @override
  ConsumerState<OutlineEditor> createState() => _OutlineEditorState();
}

class _OutlineEditorState extends ConsumerState<OutlineEditor> {
  QuillController? _controller;
  Outline? _outline;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
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
      _loadOutline();
      return;
    }

    try {
      _controller = QuillController.basic();
      _loadOutline();
    } catch (e) {
      setState(() {
        _error = '编辑器初始化失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _saveOutline();
    _controller?.dispose();
    super.dispose();
  }

  /// 加载大纲内容
  Future<void> _loadOutline() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      final outline = await repository.getOutlineForBook(widget.bookId);

      if (outline != null && outline.content.isNotEmpty) {
        try {
          final json = jsonDecode(outline.content);
          _controller?.document = Document.fromJson(json);
        } catch (_) {
          // 如果解析失败，使用空文档
        }
      }

      setState(() {
        _outline = outline;
        _isLoading = false;
      });

      // 监听内容变化
      _controller?.document.changes.listen((_) {
        if (!_hasUnsavedChanges && mounted) {
          setState(() => _hasUnsavedChanges = true);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载大纲失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 保存大纲
  Future<void> _saveOutline() async {
    if (!_hasUnsavedChanges) return;

    // Web 平台检查 _webContent，原生平台检查 _controller
    if (!kIsWeb && _controller == null) return;

    try {
      final repository = ref.read(bookRepositoryProvider);

      String content;
      if (kIsWeb) {
        // Web 平台：通过 GlobalKey 获取编辑器内容
        content = _webEditorKey.currentState?.text ?? '';
        debugPrint('Web 平台保存大纲: ${content.length} 字符');
      } else {
        // 原生平台：使用 Quill 文档
        content = jsonEncode(_controller!.document.toDelta().toJson());
      }

      if (_outline != null) {
        // 更新现有大纲
        final updatedOutline = _outline!.copyWith(content: content);
        await repository.saveOutline(updatedOutline);
        _outline = updatedOutline;
      } else {
        // 创建新大纲
        final newOutline = Outline(
          id: _uuid.v4(),
          bookId: widget.bookId,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveOutline(newOutline);

        // 更新书籍的 outlineId
        final booksState = ref.read(booksProvider);
        final book = booksState.books.firstWhere((b) => b.id == widget.bookId);
        await ref
            .read(booksProvider.notifier)
            .updateBook(book.copyWith(outlineId: newOutline.id));

        _outline = newOutline;
      }

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
      }

      debugPrint('大纲保存成功');
    } catch (e) {
      debugPrint('保存大纲失败: $e');
    }
  }

  /// Web 平台专用简单编辑器
  Widget _buildWebEditor(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 标题和保存按钮
          Row(
            children: [
              Icon(Icons.subject_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '全书大纲',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _saveOutline,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('保存'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Web 安全编辑器
          Expanded(
            child: WebSafeEditor(
              key: _webEditorKey,
              placeholder: '在这里编写您的书籍大纲...',
              onChanged: (_) {
                if (!_hasUnsavedChanges) {
                  setState(() => _hasUnsavedChanges = true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Web 平台使用简单编辑器
    if (kIsWeb) {
      return _buildWebEditor(context, colorScheme);
    }

    if (_error != null || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(_error ?? '编辑器初始化失败'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _initController,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final controller = _controller!;

    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.subject_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '全书大纲',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              if (_hasUnsavedChanges)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '未保存',
                    style: TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _hasUnsavedChanges ? _saveOutline : null,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('保存'),
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

        // 编辑器工具栏
        CardContainer(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              showDividers: true,
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showAlignmentButtons: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showHeaderStyle: true,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: true,
              showCodeBlock: false,
              showQuote: true,
              showIndent: false,
              showLink: false,
              showUndo: true,
              showRedo: true,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 编辑器内容
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(
                placeholder:
                    '在这里编写您的书籍大纲...\n\n可以包括：\n• 故事主线\n• 各卷/篇章概要\n• 重要事件节点\n• 世界观设定',
                padding: EdgeInsets.zero,
                scrollable: true,
                autoFocus: false,
                expands: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
