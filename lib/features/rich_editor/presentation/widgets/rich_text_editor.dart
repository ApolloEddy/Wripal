/// 富文本编辑器 Widget
///
/// 使用简化的 TextField 编辑器，确保桌面端稳定运行

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/chapter_rich_editor.dart';

/// 富文本编辑器 Widget
class RichTextEditor extends ConsumerStatefulWidget {
  const RichTextEditor({super.key});

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  final GlobalKey<ChapterRichEditorState> _editorKey =
      GlobalKey<ChapterRichEditorState>();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.zero,
      child: ChapterRichEditor(
        key: _editorKey,
        placeholder: '开始编辑...',
        autoFocus: true,
      ),
    );
  }
}
