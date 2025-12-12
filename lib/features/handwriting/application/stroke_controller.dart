/// 笔触控制器
///
/// 使用 Riverpod 管理画布状态和笔触操作

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/stroke.dart';
import '../domain/models/canvas_state.dart';
import '../../../core/constants/app_constants.dart';

/// UUID 生成器
const _uuid = Uuid();

/// 画布状态 Notifier
class StrokeController extends StateNotifier<CanvasState> {
  StrokeController() : super(const CanvasState());

  /// 开始绘制
  void startStroke(Offset position) {
    // 如果是橡皮擦，执行擦除逻辑
    if (state.currentTool == StrokeTool.eraser) {
      _eraseAt(position);
      return;
    }

    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final newStroke = Stroke(
      id: _uuid.v4(),
      points: [point],
      style: state.currentStyle,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = state.copyWith(currentStroke: newStroke);
  }

  /// 更新当前绘制
  void updateStroke(Offset position) {
    if (state.currentTool == StrokeTool.eraser) {
      _eraseAt(position);
      return;
    }

    if (state.currentStroke == null) return;

    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    state = state.copyWith(currentStroke: state.currentStroke!.addPoint(point));
  }

  /// 结束绘制
  void endStroke() {
    if (state.currentTool == StrokeTool.eraser) return;
    if (state.currentStroke == null) return;

    // 保存当前状态到撤销栈
    final newUndoStack = [
      ...state.undoStack,
      [...state.strokes],
    ];

    // 限制撤销栈大小
    final limitedUndoStack = newUndoStack.length > AppConstants.maxUndoSteps
        ? newUndoStack.sublist(newUndoStack.length - AppConstants.maxUndoSteps)
        : newUndoStack;

    state = state.copyWith(
      strokes: [...state.strokes, state.currentStroke!],
      undoStack: limitedUndoStack,
      redoStack: [], // 清空重做栈
      clearCurrentStroke: true,
    );
  }

  /// 擦除指定位置的笔触
  void _eraseAt(Offset position) {
    const eraserRadius = DrawingConstants.eraserWidth / 2;
    final eraserRect = Rect.fromCircle(center: position, radius: eraserRadius);

    final remainingStrokes = <Stroke>[];
    bool hasErased = false;

    for (final stroke in state.strokes) {
      // 检查笔触是否与橡皮擦区域相交
      bool shouldErase = false;
      for (final point in stroke.points) {
        if (eraserRect.contains(point.toOffset())) {
          shouldErase = true;
          break;
        }
      }

      if (!shouldErase) {
        remainingStrokes.add(stroke);
      } else {
        hasErased = true;
      }
    }

    if (hasErased) {
      // 保存到撤销栈
      final newUndoStack = [
        ...state.undoStack,
        [...state.strokes],
      ];

      state = state.copyWith(
        strokes: remainingStrokes,
        undoStack: newUndoStack,
        redoStack: [],
      );
    }
  }

  /// 撤销
  void undo() {
    if (!state.canUndo) return;

    final previousState = state.undoStack.last;
    final newUndoStack = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedoStack = [
      ...state.redoStack,
      [...state.strokes],
    ];

    state = state.copyWith(
      strokes: previousState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// 重做
  void redo() {
    if (!state.canRedo) return;

    final nextState = state.redoStack.last;
    final newRedoStack = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndoStack = [
      ...state.undoStack,
      [...state.strokes],
    ];

    state = state.copyWith(
      strokes: nextState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// 清除所有笔触
  void clearAll() {
    if (state.strokes.isEmpty) return;

    final newUndoStack = [
      ...state.undoStack,
      [...state.strokes],
    ];

    state = state.copyWith(strokes: [], undoStack: newUndoStack, redoStack: []);
  }

  /// 设置工具
  void setTool(StrokeTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  /// 设置颜色
  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  /// 设置笔触宽度
  void setWidth(double width) {
    state = state.copyWith(
      currentWidth: width.clamp(
        DrawingConstants.minStrokeWidth,
        DrawingConstants.maxStrokeWidth,
      ),
    );
  }

  /// 设置缩放
  void setScale(double scale) {
    state = state.copyWith(scale: scale.clamp(0.5, 3.0));
  }

  /// 设置偏移
  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  /// 加载笔触数据
  void loadStrokes(List<Stroke> strokes) {
    state = state.copyWith(strokes: strokes, undoStack: [], redoStack: []);
  }

  /// 获取所有笔触用于保存
  List<Stroke> getStrokes() => state.strokes;
}

/// 画布状态 Provider
final strokeControllerProvider =
    StateNotifierProvider<StrokeController, CanvasState>((ref) {
      return StrokeController();
    });
