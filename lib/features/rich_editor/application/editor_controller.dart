/// 富文本编辑器控制器
/// 
/// 使用 Riverpod 管理编辑器状态

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/document.dart';

const _uuid = Uuid();

/// 编辑器状态
class EditorState {
  /// 当前文档
  final RichDocument? currentDocument;

  /// Quill 控制器
  final QuillController quillController;

  /// 是否有未保存的更改
  final bool hasUnsavedChanges;

  EditorState({
    this.currentDocument,
    required this.quillController,
    this.hasUnsavedChanges = false,
  });

  EditorState copyWith({
    RichDocument? currentDocument,
    QuillController? quillController,
    bool? hasUnsavedChanges,
  }) {
    return EditorState(
      currentDocument: currentDocument ?? this.currentDocument,
      quillController: quillController ?? this.quillController,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// 编辑器控制器
class EditorController extends StateNotifier<EditorState> {
  EditorController()
      : super(EditorState(
          quillController: QuillController.basic(),
        )) {
    // 监听内容变化
    state.quillController.document.changes.listen((_) {
      if (!state.hasUnsavedChanges) {
        state = state.copyWith(hasUnsavedChanges: true);
      }
    });
  }

  /// 创建新文档
  void newDocument() {
    final doc = RichDocument.empty(_uuid.v4());
    state = EditorState(
      currentDocument: doc,
      quillController: QuillController.basic(),
    );
  }

  /// 加载文档
  void loadDocument(RichDocument document) {
    // TODO: 解析 document.content 为 Quill Document
    state = EditorState(
      currentDocument: document,
      quillController: QuillController.basic(),
    );
  }

  /// 保存当前文档
  RichDocument? saveDocument() {
    if (state.currentDocument == null) return null;

    final content = state.quillController.document.toDelta().toJson().toString();
    final updatedDoc = state.currentDocument!.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentDocument: updatedDoc,
      hasUnsavedChanges: false,
    );

    return updatedDoc;
  }

  /// 更新标题
  void updateTitle(String title) {
    if (state.currentDocument == null) return;

    state = state.copyWith(
      currentDocument: state.currentDocument!.copyWith(title: title),
      hasUnsavedChanges: true,
    );
  }

  /// 获取纯文本内容
  String getPlainText() {
    return state.quillController.document.toPlainText();
  }

  @override
  void dispose() {
    state.quillController.dispose();
    super.dispose();
  }
}

/// 编辑器 Provider
final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorState>((ref) {
  return EditorController();
});
