/// 富文本编辑器控制器
///
/// 使用 Riverpod 管理编辑器状态
/// 在 Web 平台上使用简单文本，在原生平台上使用 flutter_quill

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/document.dart';

const _uuid = Uuid();

/// 编辑器状态
class EditorState {
  /// 当前文档
  final RichDocument? currentDocument;

  /// Quill 控制器（仅在非 Web 平台使用）
  final QuillController? quillController;

  /// Web 平台的纯文本内容
  final String webContent;

  /// 是否有未保存的更改
  final bool hasUnsavedChanges;

  /// 是否在 Web 平台
  final bool isWeb;

  EditorState({
    this.currentDocument,
    this.quillController,
    this.webContent = '',
    this.hasUnsavedChanges = false,
    this.isWeb = false,
  });

  EditorState copyWith({
    RichDocument? currentDocument,
    QuillController? quillController,
    String? webContent,
    bool? hasUnsavedChanges,
    bool? isWeb,
  }) {
    return EditorState(
      currentDocument: currentDocument ?? this.currentDocument,
      quillController: quillController ?? this.quillController,
      webContent: webContent ?? this.webContent,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isWeb: isWeb ?? this.isWeb,
    );
  }
}

/// 编辑器控制器
class EditorController extends StateNotifier<EditorState> {
  EditorController() : super(_createInitialState()) {
    // 仅在非 Web 平台监听 Quill 内容变化
    if (!kIsWeb && state.quillController != null) {
      state.quillController!.document.changes.listen((_) {
        if (!state.hasUnsavedChanges) {
          state = state.copyWith(hasUnsavedChanges: true);
        }
      });
    }
  }

  /// 创建初始状态（平台感知）
  static EditorState _createInitialState() {
    if (kIsWeb) {
      // Web 平台：不使用 QuillController
      return EditorState(isWeb: true);
    } else {
      // 原生平台：使用 QuillController
      return EditorState(
        quillController: QuillController.basic(),
        isWeb: false,
      );
    }
  }

  /// 创建新文档
  void newDocument() {
    final doc = RichDocument.empty(_uuid.v4());
    if (kIsWeb) {
      state = EditorState(currentDocument: doc, isWeb: true, webContent: '');
    } else {
      state = EditorState(
        currentDocument: doc,
        quillController: QuillController.basic(),
        isWeb: false,
      );
    }
  }

  /// 加载文档
  void loadDocument(RichDocument document) {
    if (kIsWeb) {
      state = EditorState(
        currentDocument: document,
        isWeb: true,
        webContent: document.content,
      );
    } else {
      // TODO: 解析 document.content 为 Quill Document
      state = EditorState(
        currentDocument: document,
        quillController: QuillController.basic(),
        isWeb: false,
      );
    }
  }

  /// 保存当前文档
  RichDocument? saveDocument() {
    if (state.currentDocument == null) return null;

    String content;
    if (kIsWeb) {
      // Web 平台：使用纯文本内容
      content = state.webContent;
    } else {
      // 原生平台：使用 Quill 文档内容
      content =
          state.quillController?.document.toDelta().toJson().toString() ?? '';
    }

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
    if (kIsWeb) {
      return state.webContent;
    } else {
      return state.quillController?.document.toPlainText() ?? '';
    }
  }

  /// 更新 Web 平台内容
  void updateWebContent(String content) {
    if (kIsWeb) {
      state = state.copyWith(webContent: content, hasUnsavedChanges: true);
    }
  }

  @override
  void dispose() {
    state.quillController?.dispose();
    super.dispose();
  }
}

/// 编辑器 Provider
final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorState>((ref) {
      return EditorController();
    });
