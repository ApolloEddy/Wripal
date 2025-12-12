/// 编辑器控制器
///
/// 简化版编辑器状态管理

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 编辑器状态
class EditorState {
  final String content;
  final bool hasUnsavedChanges;

  const EditorState({this.content = '', this.hasUnsavedChanges = false});

  EditorState copyWith({String? content, bool? hasUnsavedChanges}) {
    return EditorState(
      content: content ?? this.content,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// 编辑器控制器
class EditorController extends StateNotifier<EditorState> {
  EditorController() : super(const EditorState());

  /// 更新内容
  void updateContent(String content) {
    state = state.copyWith(content: content, hasUnsavedChanges: true);
  }

  /// 保存内容
  Future<void> save() async {
    // 保存逻辑
    debugPrint('保存内容: ${state.content.length} 字符');
    state = state.copyWith(hasUnsavedChanges: false);
  }

  /// 清空内容
  void clear() {
    state = const EditorState();
  }
}

/// 编辑器控制器 Provider
final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorState>((ref) {
      return EditorController();
    });
