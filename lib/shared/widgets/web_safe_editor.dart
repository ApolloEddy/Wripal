/// 平台感知的富文本编辑器
///
/// 在原生平台使用 flutter_quill，在 Web 平台使用简单文本编辑器
/// 避免 flutter_quill 在 Web 上的兼容性问题

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// 简单的 Web 安全编辑器
/// 在 Web 平台上替代 flutter_quill
class WebSafeEditor extends StatefulWidget {
  final String? initialContent;
  final String placeholder;
  final bool autoFocus;
  final Function(String)? onChanged;
  final VoidCallback? onSave;

  const WebSafeEditor({
    super.key,
    this.initialContent,
    this.placeholder = '开始输入...',
    this.autoFocus = false,
    this.onChanged,
    this.onSave,
  });

  @override
  WebSafeEditorState createState() => WebSafeEditorState();
}

/// Web 安全编辑器状态（公开以便使用 GlobalKey 访问）
class WebSafeEditorState extends State<WebSafeEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _focusNode = FocusNode();

    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
    });

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 获取当前文本内容
  String get text => _controller.text;

  /// 设置文本内容
  set text(String value) {
    _controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 简单的格式工具栏
        _buildToolbar(context, colorScheme),

        const SizedBox(height: 8),

        // 编辑区域
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(100),
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 使用 Flexible 防止文本溢出
          Flexible(
            child: Text(
              '📝 编辑器',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_controller.text.replaceAll(RegExp(r'\s'), '').length} 字',
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
          ),
          if (widget.onSave != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onSave,
              icon: Icon(Icons.save, size: 18, color: colorScheme.primary),
              tooltip: '保存',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

/// 检查是否应该使用 Web 安全编辑器
bool get shouldUseWebSafeEditor => kIsWeb;
