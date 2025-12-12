/// 情节点数据模型
///
/// 代表书籍故事线中的一个情节点/事件
/// 用于规划和追踪故事发展
/// 支持 JSON 序列化用于 Hive 持久化存储

/// 情节状态枚举
enum PlotStatus {
  /// 计划中
  planned,

  /// 进行中
  inProgress,

  /// 已完成
  completed,
}

/// 情节类型枚举
enum PlotType {
  /// 开端
  opening,

  /// 发展/铺垫
  development,

  /// 高潮
  climax,

  /// 结局
  resolution,

  /// 支线
  subplot,

  /// 其他
  other,
}

/// 情节点模型
class PlotPoint {
  /// 唯一标识符
  final String id;

  /// 所属书籍 ID
  final String bookId;

  /// 情节标题
  final String title;

  /// 情节描述
  final String? description;

  /// 排序索引（用于情节顺序）
  final int orderIndex;

  /// 情节状态
  final PlotStatus status;

  /// 情节类型
  final PlotType type;

  /// 关联的章节 ID 列表
  final List<String> relatedChapterIds;

  /// 关联的角色 ID 列表
  final List<String> relatedCharacterIds;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const PlotPoint({
    required this.id,
    required this.bookId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.status = PlotStatus.planned,
    this.type = PlotType.development,
    this.relatedChapterIds = const [],
    this.relatedCharacterIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新情节点
  factory PlotPoint.create({
    required String id,
    required String bookId,
    required String title,
    required int orderIndex,
    PlotType type = PlotType.development,
  }) {
    final now = DateTime.now();
    return PlotPoint(
      id: id,
      bookId: bookId,
      title: title,
      orderIndex: orderIndex,
      type: type,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory PlotPoint.fromJson(Map<String, dynamic> json) {
    return PlotPoint(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['orderIndex'] as int,
      status: PlotStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PlotStatus.planned,
      ),
      type: PlotType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PlotType.development,
      ),
      relatedChapterIds:
          (json['relatedChapterIds'] as List?)?.cast<String>() ?? [],
      relatedCharacterIds:
          (json['relatedCharacterIds'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'status': status.name,
      'type': type.name,
      'relatedChapterIds': relatedChapterIds,
      'relatedCharacterIds': relatedCharacterIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  PlotPoint copyWith({
    String? title,
    String? description,
    int? orderIndex,
    PlotStatus? status,
    PlotType? type,
    List<String>? relatedChapterIds,
    List<String>? relatedCharacterIds,
    DateTime? updatedAt,
  }) {
    return PlotPoint(
      id: id,
      bookId: bookId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      status: status ?? this.status,
      type: type ?? this.type,
      relatedChapterIds: relatedChapterIds ?? this.relatedChapterIds,
      relatedCharacterIds: relatedCharacterIds ?? this.relatedCharacterIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case PlotStatus.planned:
        return '计划中';
      case PlotStatus.inProgress:
        return '进行中';
      case PlotStatus.completed:
        return '已完成';
    }
  }

  /// 获取类型显示名称
  String get typeDisplayName {
    switch (type) {
      case PlotType.opening:
        return '开端';
      case PlotType.development:
        return '发展';
      case PlotType.climax:
        return '高潮';
      case PlotType.resolution:
        return '结局';
      case PlotType.subplot:
        return '支线';
      case PlotType.other:
        return '其他';
    }
  }

  @override
  String toString() => 'PlotPoint($id, $title, $typeDisplayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotPoint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
