/// 绘图画布组件
/// 
/// 处理触摸事件并渲染笔触

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stroke_controller.dart';
import '../../domain/models/stroke.dart';
import '../../../../app/theme/color_schemes.dart';

/// 绘图画布组件
class DrawingCanvas extends ConsumerWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(strokeControllerProvider);
    final controller = ref.read(strokeControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      // 触摸开始
      onPanStart: (details) {
        controller.startStroke(details.localPosition);
      },
      // 触摸移动
      onPanUpdate: (details) {
        controller.updateStroke(details.localPosition);
      },
      // 触摸结束
      onPanEnd: (details) {
        controller.endStroke();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasDark : AppColors.canvasLight,
          ),
          child: CustomPaint(
            painter: StrokePainter(
              strokes: canvasState.strokes,
              currentStroke: canvasState.currentStroke,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// 笔触绘制器
class StrokePainter extends CustomPainter {
  /// 已完成的笔触
  final List<Stroke> strokes;

  /// 当前正在绘制的笔触
  final Stroke? currentStroke;

  StrokePainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制已完成的笔触
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // 绘制当前笔触
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  /// 绘制单个笔触
  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = stroke.style.toPaint();
    final points = stroke.points;

    if (points.length == 1) {
      // 单点绘制一个点
      canvas.drawCircle(
        points[0].toOffset(),
        paint.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    // 使用贝塞尔曲线平滑绘制
    final path = Path();
    path.moveTo(points[0].x, points[0].y);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // 计算控制点（中点）
      final midX = (current.x + next.x) / 2;
      final midY = (current.y + next.y) / 2;

      // 使用二次贝塞尔曲线
      path.quadraticBezierTo(current.x, current.y, midX, midY);
    }

    // 连接最后一个点
    final lastPoint = points.last;
    path.lineTo(lastPoint.x, lastPoint.y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke;
  }
}
