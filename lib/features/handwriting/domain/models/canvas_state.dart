/// 画布状态模型
/// 
/// 管理画布的当前状态，包括笔触列表、选中工具、缩放等

import 'package:flutter/material.dart';

import 'stroke.dart';

/// 画布状态
class CanvasState {
  /// 所有笔触
  final List<Stroke> strokes;

  /// 当前正在绘制的笔触
  final Stroke? currentStroke;

  /// 当前工具
  final StrokeTool currentTool;

  /// 当前颜色
  final Color currentColor;

  /// 当前笔触宽度
  final double currentWidth;

  /// 撤销栈
  final List<List<Stroke>> undoStack;

  /// 重做栈
  final List<List<Stroke>> redoStack;

  /// 缩放比例
  final double scale;

  /// 偏移量
  final Offset offset;

  const CanvasState({
    this.strokes = const [],
    this.currentStroke,
    this.currentTool = StrokeTool.pen,
    this.currentColor = Colors.black,
    this.currentWidth = 2.0,
    this.undoStack = const [],
    this.redoStack = const [],
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  /// 是否可以撤销
  bool get canUndo => undoStack.isNotEmpty;

  /// 是否可以重做
  bool get canRedo => redoStack.isNotEmpty;

  /// 当前笔触样式
  StrokeStyle get currentStyle => StrokeStyle(
        color: currentColor,
        width: currentWidth,
        tool: currentTool,
        opacity: currentTool == StrokeTool.highlighter ? 0.4 : 1.0,
      );

  CanvasState copyWith({
    List<Stroke>? strokes,
    Stroke? currentStroke,
    StrokeTool? currentTool,
    Color? currentColor,
    double? currentWidth,
    List<List<Stroke>>? undoStack,
    List<List<Stroke>>? redoStack,
    double? scale,
    Offset? offset,
    bool clearCurrentStroke = false,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      currentStroke: clearCurrentStroke ? null : (currentStroke ?? this.currentStroke),
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentWidth: currentWidth ?? this.currentWidth,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
    );
  }
}
