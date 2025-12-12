/// 情节时间线组件
///
/// 展示书籍的情节发展，支持创建、编辑和删除情节点

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../application/providers.dart';
import '../../domain/models/plot_point.dart';

const _uuid = Uuid();

/// 情节时间线组件
class PlotTimeline extends ConsumerWidget {
  final String bookId;

  const PlotTimeline({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotPointsAsync = ref.watch(plotPointsProvider(bookId));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              plotPointsAsync.when(
                data: (plots) => Text(
                  '共 ${plots.length} 个情节点',
                  style: TextStyle(color: colorScheme.outline),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreatePlotDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建情节'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 情节时间线
        Expanded(
          child: plotPointsAsync.when(
            data: (plotPoints) => _buildTimeline(context, ref, plotPoints),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('加载失败：$error')),
          ),
        ),
      ],
    );
  }

  /// 构建时间线
  Widget _buildTimeline(
    BuildContext context,
    WidgetRef ref,
    List<PlotPoint> plotPoints,
  ) {
    if (plotPoints.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: plotPoints.length,
      itemBuilder: (context, index) {
        final plotPoint = plotPoints[index];
        final isLast = index == plotPoints.length - 1;

        return _PlotPointTile(
          plotPoint: plotPoint,
          isLast: isLast,
          onTap: () => _showEditPlotDialog(context, ref, plotPoint),
          onDelete: () => _deletePlotPoint(context, ref, plotPoint),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text('还没有创建任何情节点', style: TextStyle(color: colorScheme.outline)),
          const SizedBox(height: 8),
          Text(
            '情节点可以帮助您规划故事发展',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => _showCreatePlotDialog(context, ref),
            child: const Text('创建第一个情节'),
          ),
        ],
      ),
    );
  }

  /// 显示创建情节对话框
  Future<void> _showCreatePlotDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    PlotType selectedType = PlotType.development;

    final plotPoints = await ref.read(plotPointsProvider(bookId).future);
    final nextOrder = plotPoints.length;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新建情节'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '情节标题',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PlotType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '情节类型',
                    border: OutlineInputBorder(),
                  ),
                  items: PlotType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '情节描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final plotPoint =
          PlotPoint.create(
            id: _uuid.v4(),
            bookId: bookId,
            title: titleController.text,
            orderIndex: nextOrder,
            type: selectedType,
          ).copyWith(
            description: descriptionController.text.isEmpty
                ? null
                : descriptionController.text,
          );

      final repository = ref.read(bookRepositoryProvider);
      await repository.savePlotPoint(plotPoint);

      ref.invalidate(plotPointsProvider(bookId));
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  /// 显示编辑情节对话框
  Future<void> _showEditPlotDialog(
    BuildContext context,
    WidgetRef ref,
    PlotPoint plotPoint,
  ) async {
    final titleController = TextEditingController(text: plotPoint.title);
    final descriptionController = TextEditingController(
      text: plotPoint.description ?? '',
    );
    PlotType selectedType = plotPoint.type;
    PlotStatus selectedStatus = plotPoint.status;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑情节'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '情节标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PlotType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: '类型',
                          border: OutlineInputBorder(),
                        ),
                        items: PlotType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PlotStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '状态',
                          border: OutlineInputBorder(),
                        ),
                        items: PlotStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusDisplayName(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatus = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '情节描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final updatedPlot = plotPoint.copyWith(
        title: titleController.text,
        type: selectedType,
        status: selectedStatus,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
      );

      final repository = ref.read(bookRepositoryProvider);
      await repository.savePlotPoint(updatedPlot);

      ref.invalidate(plotPointsProvider(bookId));
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  /// 删除情节点
  Future<void> _deletePlotPoint(
    BuildContext context,
    WidgetRef ref,
    PlotPoint plotPoint,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除情节'),
        content: Text('确定要删除情节「${plotPoint.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(bookRepositoryProvider);
      await repository.deletePlotPoint(plotPoint.id);
      ref.invalidate(plotPointsProvider(bookId));
    }
  }

  String _getTypeDisplayName(PlotType type) {
    return switch (type) {
      PlotType.opening => '开端',
      PlotType.development => '发展',
      PlotType.climax => '高潮',
      PlotType.resolution => '结局',
      PlotType.subplot => '支线',
      PlotType.other => '其他',
    };
  }

  String _getStatusDisplayName(PlotStatus status) {
    return switch (status) {
      PlotStatus.planned => '计划中',
      PlotStatus.inProgress => '进行中',
      PlotStatus.completed => '已完成',
    };
  }
}

/// 情节点瓷砖
class _PlotPointTile extends StatelessWidget {
  final PlotPoint plotPoint;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlotPointTile({
    required this.plotPoint,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final typeColor = switch (plotPoint.type) {
      PlotType.opening => Colors.green,
      PlotType.development => Colors.blue,
      PlotType.climax => Colors.orange,
      PlotType.resolution => Colors.purple,
      PlotType.subplot => Colors.teal,
      PlotType.other => Colors.grey,
    };

    final statusIcon = switch (plotPoint.status) {
      PlotStatus.planned => Icons.schedule,
      PlotStatus.inProgress => Icons.edit,
      PlotStatus.completed => Icons.check_circle,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 时间线
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: typeColor.withAlpha(100)),
                  ),
              ],
            ),
          ),

          // 内容卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardContainer(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: onTap,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: typeColor, size: 20),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          plotPoint.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plotPoint.typeDisplayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: plotPoint.description != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            plotPoint.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
