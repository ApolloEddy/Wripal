/// 工具栏组件
/// 
/// 提供笔触工具、颜色、宽度选择

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stroke_controller.dart';
import '../../domain/models/stroke.dart';
import '../../domain/models/canvas_state.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../../shared/widgets/card_container.dart';

/// 工具栏组件
class ToolPalette extends ConsumerWidget {
  const ToolPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(strokeControllerProvider);
    final controller = ref.read(strokeControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 工具选择
          _buildToolButtons(context, ref, canvasState, controller),
          
          const SizedBox(width: 16),
          
          // 分隔线
          Container(
            height: 32,
            width: 1,
            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
          ),
          
          const SizedBox(width: 16),
          
          // 颜色选择
          _buildColorPicker(context, ref, canvasState, controller),
          
          const SizedBox(width: 16),
          
          // 分隔线
          Container(
            height: 32,
            width: 1,
            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
          ),
          
          const SizedBox(width: 16),
          
          // 宽度调节
          _buildWidthSlider(context, ref, canvasState, controller),
          
          const Spacer(),
          
          // 操作按钮
          _buildActionButtons(context, ref, canvasState, controller),
        ],
      ),
    );
  }

  /// 构建工具按钮
  Widget _buildToolButtons(
    BuildContext context,
    WidgetRef ref,
    CanvasState state,
    StrokeController controller,
  ) {
    return Row(
      children: [
        _ToolButton(
          icon: Icons.edit_rounded,
          tooltip: '钢笔',
          isSelected: state.currentTool == StrokeTool.pen,
          onTap: () => controller.setTool(StrokeTool.pen),
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.brush_rounded,
          tooltip: '铅笔',
          isSelected: state.currentTool == StrokeTool.pencil,
          onTap: () => controller.setTool(StrokeTool.pencil),
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.highlight_rounded,
          tooltip: '荧光笔',
          isSelected: state.currentTool == StrokeTool.highlighter,
          onTap: () => controller.setTool(StrokeTool.highlighter),
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.auto_fix_high_rounded,
          tooltip: '橡皮擦',
          isSelected: state.currentTool == StrokeTool.eraser,
          onTap: () => controller.setTool(StrokeTool.eraser),
        ),
      ],
    );
  }

  /// 构建颜色选择器
  Widget _buildColorPicker(
    BuildContext context,
    WidgetRef ref,
    CanvasState state,
    StrokeController controller,
  ) {
    return Row(
      children: AppColors.strokeColors.map((color) {
        final isSelected = state.currentColor.value == color.value;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => controller.setColor(color),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withAlpha((0.4 * 255).round()),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建宽度滑块
  Widget _buildWidthSlider(
    BuildContext context,
    WidgetRef ref,
    CanvasState state,
    StrokeController controller,
  ) {
    return Row(
      children: [
        const Icon(Icons.line_weight_rounded, size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Slider(
            value: state.currentWidth,
            min: 0.5,
            max: 20.0,
            onChanged: (value) => controller.setWidth(value),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            state.currentWidth.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    CanvasState state,
    StrokeController controller,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.undo_rounded),
          tooltip: '撤销',
          onPressed: state.canUndo ? () => controller.undo() : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo_rounded),
          tooltip: '重做',
          onPressed: state.canRedo ? () => controller.redo() : null,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: '清除全部',
          onPressed: state.strokes.isNotEmpty 
              ? () => _showClearConfirmDialog(context, controller)
              : null,
        ),
      ],
    );
  }

  /// 显示清除确认对话框
  void _showClearConfirmDialog(BuildContext context, StrokeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除全部'),
        content: const Text('确定要清除所有笔触吗？此操作可以撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              controller.clearAll();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 工具按钮
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected 
            ? colorScheme.primary.withAlpha((0.15 * 255).round())
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
        ),
      ),
    );
  }
}
