/// 富文本编辑器 Widget
///
/// 在原生平台使用 flutter_quill，在 Web 平台使用简单编辑器

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/web_safe_editor.dart';

/// 富文本编辑器 Widget
class RichTextEditor extends ConsumerStatefulWidget {
  const RichTextEditor({super.key});

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  QuillController? _controller;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  void _initEditor() {
    if (kIsWeb) {
      // Web 平台直接显示
      setState(() => _isLoading = false);
    } else {
      // 原生平台使用 Quill
      try {
        _controller = QuillController.basic();
        setState(() => _isLoading = false);
      } catch (e) {
        setState(() {
          _error = '编辑器初始化失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Web 平台使用 WebSafeEditor
    if (kIsWeb) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: const WebSafeEditor(placeholder: '开始输入内容...', autoFocus: false),
      );
    }

    // 原生平台使用 flutter_quill
    if (_error != null || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error ?? '编辑器初始化失败'),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: _initEditor, child: const Text('重试')),
          ],
        ),
      );
    }

    final controller = _controller!;

    return Column(
      children: [
        // 工具栏
        CardContainer(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(),
          ),
        ),

        // 编辑区域
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(
                placeholder: '开始输入内容...',
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
