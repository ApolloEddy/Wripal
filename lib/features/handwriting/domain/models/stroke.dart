/// 笔触数据模型
/// 
/// 存储单次绘制的完整笔触路径
/// 包含点序列、样式等信息，支持序列化用于持久化存储

import 'package:flutter/material.dart';

/// 笔触点
/// 
/// 记录单个点的位置和压力信息
class StrokePoint {
  /// X 坐标
  final double x;

  /// Y 坐标
  final double y;

  /// 压力值 (0.0 - 1.0)
  final double pressure;

  /// 时间戳（毫秒）
  final int timestamp;

  const StrokePoint({
    required this.x,
    required this.y,
    this.pressure = 1.0,
    required this.timestamp,
  });

  /// 转换为 Offset
  Offset toOffset() => Offset(x, y);

  /// 从 JSON 反序列化
  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
      timestamp: json['timestamp'] as int,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'pressure': pressure,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() => 'StrokePoint($x, $y, p: $pressure)';
}

/// 笔触工具类型
enum StrokeTool {
  /// 钢笔
  pen,
  
  /// 铅笔（纹理）
  pencil,
  
  /// 荧光笔
  highlighter,
  
  /// 橡皮擦
  eraser,
}

/// 笔触样式
class StrokeStyle {
  /// 颜色
  final Color color;

  /// 宽度
  final double width;

  /// 工具类型
  final StrokeTool tool;

  /// 透明度 (0.0 - 1.0)
  final double opacity;

  const StrokeStyle({
    this.color = Colors.black,
    this.width = 2.0,
    this.tool = StrokeTool.pen,
    this.opacity = 1.0,
  });

  /// 创建 Paint 对象
  Paint toPaint() {
    return Paint()
      ..color = color.withAlpha((opacity * 255).round())
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
  }

  /// 从 JSON 反序列化
  factory StrokeStyle.fromJson(Map<String, dynamic> json) {
    return StrokeStyle(
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      tool: StrokeTool.values[json['tool'] as int],
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'color': color.value,
      'width': width,
      'tool': tool.index,
      'opacity': opacity,
    };
  }

  StrokeStyle copyWith({
    Color? color,
    double? width,
    StrokeTool? tool,
    double? opacity,
  }) {
    return StrokeStyle(
      color: color ?? this.color,
      width: width ?? this.width,
      tool: tool ?? this.tool,
      opacity: opacity ?? this.opacity,
    );
  }
}

/// 笔触数据模型
/// 
/// 存储单次绘制的完整笔触路径
class Stroke {
  /// 唯一标识符
  final String id;

  /// 笔触点列表
  final List<StrokePoint> points;

  /// 笔触样式
  final StrokeStyle style;

  /// 创建时间戳
  final int createdAt;

  const Stroke({
    required this.id,
    required this.points,
    required this.style,
    required this.createdAt,
  });

  /// 添加点
  Stroke addPoint(StrokePoint point) {
    return Stroke(
      id: id,
      points: [...points, point],
      style: style,
      createdAt: createdAt,
    );
  }

  /// 获取边界矩形
  Rect get bounds {
    if (points.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    // 考虑笔触宽度
    final halfWidth = style.width / 2;
    return Rect.fromLTRB(
      minX - halfWidth,
      minY - halfWidth,
      maxX + halfWidth,
      maxY + halfWidth,
    );
  }

  /// 从 JSON 反序列化
  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      id: json['id'] as String,
      points: (json['points'] as List)
          .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      style: StrokeStyle.fromJson(json['style'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as int,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((p) => p.toJson()).toList(),
      'style': style.toJson(),
      'createdAt': createdAt,
    };
  }

  @override
  String toString() => 'Stroke($id, ${points.length} points)';
}
