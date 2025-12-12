/// 大纲编辑器组件
///
/// 使用简化编辑器显示和编辑书籍大纲

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/chapter_rich_editor.dart';
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
  Outline? _outline;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  String? _error;

  /// 编辑器 Key（用于获取内容）
  final GlobalKey<ChapterRichEditorState> _editorKey =
      GlobalKey<ChapterRichEditorState>();

  @override
  void initState() {
    super.initState();
    _loadOutline();
  }

  /// 加载大纲内容
  Future<void> _loadOutline() async {
    try {
      final repository = ref.read(bookRepositoryProvider);
      final outline = await repository.getOutline(widget.bookId);

      if (outline == null) {
        // 创建新大纲
        final newOutline = Outline(
          id: _uuid.v4(),
          bookId: widget.bookId,
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveOutline(newOutline);
        _outline = newOutline;
      } else {
        _outline = outline;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载大纲失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 保存大纲内容
  Future<void> _saveOutline() async {
    if (!_hasUnsavedChanges || _outline == null) return;

    try {
      final repository = ref.read(bookRepositoryProvider);

      // 获取编辑器内容
      final content = _editorKey.currentState?.text ?? '';

      debugPrint('保存大纲: ${content.length} 字符');

      final updatedOutline = _outline!.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );
      await repository.saveOutline(updatedOutline);
      _outline = updatedOutline;

      if (mounted) setState(() => _hasUnsavedChanges = false);
    } catch (e) {
      debugPrint('保存大纲失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 工具栏
        _buildToolbar(context, colorScheme),

        // 编辑器
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            padding: EdgeInsets.zero,
            child: ChapterRichEditor(
              key: _editorKey,
              initialContent: _outline?.content,
              placeholder: '在这里编写书籍大纲...',
              autoFocus: false,
              onChanged: (_) {
                if (!_hasUnsavedChanges) {
                  setState(() => _hasUnsavedChanges = true);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 构建工具栏
  Widget _buildToolbar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          const Icon(Icons.subject_outlined, size: 20),
          const SizedBox(width: 8),
          Text('大纲编辑', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (_hasUnsavedChanges)
            Text(
              '未保存',
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _hasUnsavedChanges ? _saveOutline : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
