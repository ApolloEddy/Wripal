/// 富文本编辑器组件
///
/// 使用 fleather 实现富文本编辑，内置可隐藏工具栏

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';

/// 章节富文本编辑器组件
class ChapterRichEditor extends StatefulWidget {
  /// 初始内容 (JSON 格式的 Delta)
  final String? initialContent;

  /// 占位符
  final String placeholder;

  /// 内容变化回调
  final ValueChanged<String>? onChanged;

  /// 自动获取焦点
  final bool autoFocus;

  /// 显示工具栏
  final bool showToolbar;

  const ChapterRichEditor({
    super.key,
    this.initialContent,
    this.placeholder = '开始写作...',
    this.onChanged,
    this.autoFocus = true,
    this.showToolbar = true,
  });

  @override
  State<ChapterRichEditor> createState() => ChapterRichEditorState();
}

class ChapterRichEditorState extends State<ChapterRichEditor> {
  FleatherController? _controller;
  FocusNode? _focusNode;
  bool _toolbarVisible = true;

  @override
  void initState() {
    super.initState();
    _toolbarVisible = widget.showToolbar;
    _focusNode = FocusNode();
    _initController();
  }

  void _initController() {
    ParchmentDocument document;

    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final json = jsonDecode(widget.initialContent!);
        if (json is List) {
          document = ParchmentDocument.fromJson(json);
        } else {
          document = ParchmentDocument();
          document.insert(0, widget.initialContent!);
        }
      } catch (e) {
        document = ParchmentDocument();
        document.insert(0, widget.initialContent!);
      }
    } else {
      document = ParchmentDocument();
    }

    _controller = FleatherController(document: document);
    _controller!.document.changes.listen((_) {
      widget.onChanged?.call(getContent());
    });

    setState(() {});

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode?.requestFocus();
      });
    }
  }

  /// 获取内容 (JSON 格式)
  String getContent() {
    if (_controller == null) return '';
    try {
      return jsonEncode(_controller!.document.toDelta().toJson());
    } catch (e) {
      return '';
    }
  }

  /// 获取纯文本内容
  String get text => _controller?.document.toPlainText() ?? '';

  /// 设置内容
  void setText(String content) {
    ParchmentDocument document;
    try {
      final json = jsonDecode(content);
      if (json is List) {
        document = ParchmentDocument.fromJson(json);
      } else {
        document = ParchmentDocument();
        document.insert(0, content);
      }
    } catch (e) {
      document = ParchmentDocument();
      document.insert(0, content);
    }

    _controller = FleatherController(document: document);
    setState(() {});
  }

  void showToolbar() => setState(() => _toolbarVisible = true);
  void hideToolbar() => setState(() => _toolbarVisible = false);
  void toggleToolbar() => setState(() => _toolbarVisible = !_toolbarVisible);
  bool get isToolbarVisible => _toolbarVisible;

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 工具栏
        if (_toolbarVisible) _buildToolbar(colorScheme),

        // 编辑器
        Expanded(
          child: Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: FleatherEditor(
              controller: _controller!,
              focusNode: _focusNode,
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // 展开按钮
        if (!_toolbarVisible) _buildToolbarToggle(colorScheme),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FleatherToolbar.basic(controller: _controller!),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            tooltip: '隐藏工具栏',
            onPressed: hideToolbar,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
        ),
      ),
      child: TextButton.icon(
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        label: const Text('显示工具栏'),
        onPressed: showToolbar,
      ),
    );
  }
}
