/// 富文本编辑器 Widget
/// 
/// 集成 flutter_quill 的编辑器组件

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../shared/widgets/card_container.dart';

/// Quill 控制器 Provider
final quillControllerProvider = Provider<QuillController>((ref) {
  return QuillController.basic();
});

/// 富文本编辑器 Widget
class RichTextEditor extends ConsumerStatefulWidget {
  const RichTextEditor({super.key});

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        CardContainer(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(),
          ),
        ),

        // 编辑区域
        Expanded(
          child: CardContainer(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: _controller,
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
